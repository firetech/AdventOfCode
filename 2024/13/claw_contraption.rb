require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@machines = []
File.read(file).rstrip.split("\n\n").each do |block|
  machine = {}
  block.split("\n").each do |line|
    case line
    when /\AButton ([AB]): X\+(\d+), Y\+(\d+)\z/
      machine[Regexp.last_match(1).downcase.to_sym] = {
        x: Regexp.last_match(2).to_i,
        y: Regexp.last_match(3).to_i
      }
    when /\APrize: X=(\d+), Y=(\d+)\z/
      machine[:out] = {
        x: Regexp.last_match(1).to_i,
        y: Regexp.last_match(2).to_i
      }
    else
      raise "Malformed line: '#{line}'"
    end
  end
  @machines << machine
end

# [ Part 1, Part 2 ]
OFFSETS = [0, 10000000000000]
sum = [0, 0]

@machines.each do |m|
  OFFSETS.each_with_index do |offset, i|
    # First calculate the number of A button pushes (a):
    # a_x*a + b_x*b = out_x
    # a_y*a + b_y*b = out_y
    # => (multiply the first equation with b_y and the second with b_x)
    # a_x*b_y*a + b_x*b_y*b = out_x*b_y
    # a_y*b_x*a + b_x*b_y*b = out_y*b_x
    # => (subtract the second equation from the first)
    # a_x*b_y*a - a_y*b_x*a = out_x*b_y - out_y*b_x
    # => (simplify)
    # a = (out_x*b_y - out_y*b_x) / (a_x*b_y - a_y*b_x)
    a = ((m[:out][:x]+offset)*m[:b][:y] - (m[:out][:y]+offset)*m[:b][:x]) /
      (m[:a][:x]*m[:b][:y] - m[:a][:y]*m[:b][:x]).to_f
    next unless a.to_i == a # Non-integer => not solvable

    # Then use that value to get the number of B button pushes (b).
    # a_x*a + b_x*b = out_x
    # => (move the a term to the right side)
    # b_x*b = out_x - a_x*a
    # => (divide both sides by b_x)
    # b = (out_x - a_x*a) / b_x
    b = (m[:out][:x] + offset - m[:a][:x]*a) / m[:b][:x]
    next unless b.to_i == b # Non-integer => not solvable

    sum[i] += a.to_i * 3 + b.to_i
  end
end

# Part 1
puts "Fewest tokens to spend: #{sum[0]}"

# Part 2
puts "Fewest tokens to spend (with corrected units): #{sum[1]}"
