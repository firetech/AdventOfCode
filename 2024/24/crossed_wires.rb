require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'fixed_input'
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
def get_gate(gate)
  g = @inversenet[gate]
  g = @inversenet[gate.reverse] if g.nil?
  raise "No gate matches #{gate.join(' ')}!" if g.nil?
  return g
end
def assert_gate(name, gate)
  actual_name = get_gate(gate)
  return if actual_name == name
  raise "#{gate.join(' ')} should be #{name} instead of #{actual_name}"
end

@map = {}
last_i = @z_keys.length - 1
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
# zn = c(n-1)
@z_keys.each_with_index do |z, i|
  begin
    if i == 0
      assert_gate(z, ['x00', :XOR, 'y00'])
      @map['c00'] = get_gate(['x00', :AND, 'y00'])
    elsif i < last_i
      @map['u%02d' % i] = get_gate(['x%02i' % i, :XOR, 'y%02i' % i])
      @map['v%02d' % i] = get_gate(['x%02i' % i, :AND, 'y%02i' % i])
      assert_gate(z, [@map['c%02i' % (i-1)], :XOR, @map['u%02d' % i]])
      @map['w%02d' % i] = get_gate([@map['c%02i' % (i-1)], :AND, @map['u%02d' % i]])
      @map['c%02d' % i] = get_gate([@map['v%02i' % i], :OR, @map['w%02d' % i]])
    else
      actual_name = @map['c%02d' % (i - 1)]
      raise "#{actual_name} should be #{z}" unless actual_name == z
    end
  rescue => e
    puts "#{z} has error: #{e.message}"
    fixed = false
    break
  end
end
# Swap wires in network manually and fill this in...
@swaps = []
puts "Needed swaps: #{@swaps.sort.join(',')}" if fixed
