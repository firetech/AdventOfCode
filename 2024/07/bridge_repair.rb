require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@equations = []
File.read(file).rstrip.split("\n").each do |line|
  case line
  when /\A(\d+):((?:\s+\d+)+)\z/
    @equations << [
      Regexp.last_match(1).to_i,
      Regexp.last_match(2).strip.split(/\s+/).map(&:to_i)
    ]
  else
    raise "Malformed line: '#{line}'"
  end
end

PART1_OPERATORS = [:+, :*]
PART2_OPERATORS = [:+, :*, :join]

def is_possible(result, operands, operators)
  # DFS into the decision tree
  first_operand, *rest_operands = operands
  stack = [[first_operand, rest_operands]]
  until stack.empty?
    value, operands_left = stack.pop

    this_operand, *next_operands = operands_left

    operators.each do |op|
      if op == :join
        new_value = "#{value}#{this_operand}".to_i
      else
        new_value = value.send(op, this_operand)
      end
      if next_operands.empty?
        if new_value == result
          return true
        end
      elsif new_value <= result
        # All operations are increasing the resulting value, so intermediate
        # values will never be > the result (as long as no operand is 0, which
        # seems to be the case). It can, however be == result, since the rest
        # of the operands may be 1.
        stack << [new_value, next_operands]
      end
    end
  end
  return false
end

# Part 1
true_sum = 0
@equations.each do |result, operands|
  if is_possible(result, operands, PART1_OPERATORS)
    true_sum += result
  end
end
puts "Total calibration result: #{true_sum}"

# Part 2
true_sum_concat = 0
@equations.each do |result, operands|
  if is_possible(result, operands, PART2_OPERATORS)
    true_sum_concat += result
  end
end
puts "Total calibration result with concatenation: #{true_sum_concat}"
