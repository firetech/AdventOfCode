require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'
#file = 'example2'

inputs, outputs = File.read(file).rstrip.split("\n\n")

@network = {}
inputs.split("\n").each do |line|
  case line
  when /\A([a-z0-9]+): (0|1)\z/
    @network[Regexp.last_match(1)] = (Regexp.last_match(2) == '1')
  else
    raise "Malformed line: '#{line}'"
  end
end

outputs.split("\n").each do |line|
  case line
  when /\A([a-z0-9]+) (AND|OR|XOR) ([a-z0-9]+) -> ([a-z0-9]+)\z/
    @network[Regexp.last_match(4)] = [
      Regexp.last_match(1),
      Regexp.last_match(2).to_sym,
      Regexp.last_match(3)
    ]
  else
    raise "Malformed line: '#{line}'"
  end
end

# Part 1
def network_eval(output)
  val = @network[output]
  case val
  when true, false
    return val
  when Array
    a, op, b = val
    case op
    when :AND
      return (network_eval(a) and network_eval(b))
    when :OR
      return (network_eval(a) or network_eval(b))
    when :XOR
      return (network_eval(a) ^ network_eval(b))
    end
  end
  raise 'Ehm?'
end

@z_keys = @network.keys.filter { |k| k.start_with?('z') }.sort
num = 0
@z_keys.reverse_each do |z|
  num <<= 1
  if network_eval(z)
    num |= 1
  end
end
puts "Decimal output: #{num}"

# Part 2
@inversenet = @network.invert
@remap = Hash.new { |_, line| line } # Default value is itself
def swap(a, b)
  raise 'Cannot swap nil!' if a.nil? or b.nil?
  @remap[a] = b
  @remap[b] = a
  return b, a
end
def get_gate(gate, raise_on_nil = true)
  name = @inversenet[gate]
  name = @inversenet[gate.reverse] if name.nil?
  raise "No gate matches #{gate.join(' ')}!" if raise_on_nil and name.nil?
  return @remap[name]
end
def assert_gate(expected, gate)
  name = get_gate(gate, false)
  if name != expected and not name.nil?
    swap(name, expected)
  end
  return name
end

last_i = @z_keys.length - 1
carry = nil
fixed = true
# Full adder for z = x + y (bit 00 is LSB):
# z00 = x00 XOR y00  (no carry in)
# c00 = x00 AND y00
#
# ui = xi XOR yi
# vi = xi AND yi
# zi = c(i-1) XOR ui
# wi = c(i-1) AND ui
# ci = vi OR wi
#
# zN = c(N-1)  (where N is the maximum index)
@z_keys.each_with_index do |z, i|
  begin
    if i == 0
      assert_gate(z, ['x00', :XOR, 'y00'])
      carry = get_gate(['x00', :AND, 'y00'])
    elsif i < last_i
      u = get_gate(['x%02i' % i, :XOR, 'y%02i' % i])
      v = get_gate(['x%02i' % i, :AND, 'y%02i' % i])
      if assert_gate(z, [carry, :XOR, u]).nil?
        u, v = swap(u, v)
        raise "I don't know what to do :(" if assert_gate(z, [carry, :XOR, u]).nil?
      end
      # Fetch u and v again incase they were swapped with zXX
      u = get_gate(['x%02i' % i, :XOR, 'y%02i' % i])
      v = get_gate(['x%02i' % i, :AND, 'y%02i' % i])
      w = get_gate([carry, :AND, u])
      carry = get_gate([v, :OR, w])
    else
      swap(carry, z) if carry != z
    end
  rescue => e
    puts "#{z} has error: #{e.message}"
    puts e.backtrace.join("\n")
    fixed = false
    break
  end
end
# Swap wires in network manually and fill this in...
puts "Needed swaps: #{@remap.keys.sort.join(',')}" if fixed
