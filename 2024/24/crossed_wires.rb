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
  raise "#{a} is already swapped" if @remap.has_key?(a)
  raise "#{b} is already swapped" if @remap.has_key?(b)
  @remap[a] = b
  @remap[b] = a
  return b, a
end
def get_gate(gate)
  name = @inversenet[gate]
  name = @inversenet[gate.reverse] if name.nil?
  raise "No gate matches #{gate.join(' ')}!" if name.nil?
  return @remap[name]
end
def assert_gate(expected, gate)
  name = get_gate(gate)
  assert_name(expected, name)
end
def assert_name(expected, name)
  if name != expected
    swap(name, expected)
  end
end

last_i = @z_keys.length - 1
carry = nil
# Full adder for z = x + y (bit 00 is LSB):
# z00 = x00 XOR y00  (no carry in)
# carry = x00 AND y00
# ...
# x_xor_y = xNN XOR yNN
# x_and_y = xNN AND yNN
# zNN = carry XOR x_xor_y
# c_and_xor = carry AND x_xor_y
# carry = x_and_y OR c_and_xor
# ...
# zMM = carry  (where MM is the maximum index)
#
# The solution below is not _fully_ general. There are some possible corner
# cases that aren't handled. The ones I'm aware of are specifically checked for.
# However, it works correctly on at least the two inputs I've tested. There
# seems to be a pattern in which types of swaps are present in the inputs.
@z_keys.each_with_index do |z, i|
  if i == 0
    # First adder is simpler. Since the problem states that only gate output
    # wires have been swapped, these two gates _must_ exist.
    assert_gate(z, ['x00', :XOR, 'y00'])
    carry = get_gate(['x00', :AND, 'y00'])
  elsif i < last_i
    # Again, since only gate outputs are swapped, these gates _must_ exist.
    x_xor_y = get_gate(['x%02i' % i, :XOR, 'y%02i' % i])
    x_and_y = get_gate(['x%02i' % i, :AND, 'y%02i' % i])
    begin
      assert_gate(z, [carry, :XOR, x_xor_y])
      # Update x_and_y if it was swapped with zNN and remapped by assert_gate.
      x_and_y = @remap[x_and_y] if x_and_y == z
    rescue
      # In case x_xor_y and/or carry output has been swapped, the expected zNN
      # gate will not be found, and we end up here. Try to fix it and retry the
      # assert_gate call.
      a, op, b = @network[z]
      raise "#{z} is not an XOR gate, are both it and one of its expected " \
            "inputs swapped?" if op != :XOR
      if a == carry or b == carry
        a, b = b, a if b == carry # Make sure a is carry.
        b, x_xor_y = swap(b, x_xor_y)
        # In case x_xor_y was swapped specifically with x_and_y (which seems to
        # be what it gets swapped with), we need to also update that gate name.
        x_and_y = b if x_and_y == x_xor_y
      elsif a == x_xor_y or b == x_xor_y
        # This case doesn't appear in any tested input, so this is untested.
        a, b = b, a if b == x_xor_y # Make sure a is x_xor_y.
        b, carry = swap(b, carry)
        # In case carry was swapped specifically with x_and_y, we need to also
        # update that gate name.
        x_and_y = b if x_and_y == carry
      else
        # No input gate is recognized (doesn't happen in any tested input).
        raise "Unable to fix #{z}, are both #{carry} and #{x_xor_y} swapped?"
      end
      retry
    end
    # At this point, we should be certain that carry and x_xor_y are correctly
    # connected (including any swaps from above), since we could find the zNN
    # gate. This gate should therefore exist.
    c_and_xor = get_gate([carry, :AND, x_xor_y])
    # This might, however, fail. The gate itself must exist, but either of its
    # input gates might have their output wires swapped, making it hard to find
    # (thankfully, that hasn't happened in any tested input).
    begin
      carry = get_gate([x_and_y, :OR, c_and_xor])
    rescue
      raise "#{z} carry was not found. #{x_and_y} and/or #{c_and_xor} swapped?"
    end
  else
    # Last zNN should just be the last carry.
    assert_name(z, carry)
  end
end
puts "Needed swaps: #{@remap.keys.sort.join(',')}"
