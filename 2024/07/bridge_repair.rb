require_relative '../../lib/aoc'
require_relative '../../lib/multicore'

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

OPERATORS = [:add, :mul] # Part 1
JOIN_OPERATORS = OPERATORS + [:join] # Part 2

def is_possible(result, operands, allow_join = false)
  # DFS into the decision tree
  stack = [[operands[0], 1]]
  last_i = operands.length - 1
  operators = allow_join ? JOIN_OPERATORS : OPERATORS
  until stack.empty?
    value, i = stack.pop

    this_operand = operands[i]

    operators.each do |op|
      case op
      when :add
        new_value = value + this_operand
      when :mul
        new_value = value * this_operand
      when :join
        shift = 10**(Math.log10(this_operand).floor + 1)
        new_value = value * shift + this_operand
      end
      if i == last_i
        return true if new_value == result
      elsif new_value <= result
        # All operations are increasing the resulting value, so intermediate
        # values will never be > the result (as long as no operand is 0, which
        # seems to be the case). It can, however be == result, since the rest
        # of the operands may be 1.
        stack << [new_value, i+1]
      end
    end
  end
  return false
end

true_sum = 0 # Part 1
true_sum_concat = 0 # Part 2
stop = nil
begin
  input, output, stop = Multicore.run do |worker_in, worker_out|
    until (list = worker_in[]).nil?
      results = [0, 0]
      list.each do |result, operands|
        if is_possible(result, operands)
          results[0] += result
          results[1] += result
        elsif is_possible(result, operands, true)
          results[1] += result
        end
      end
      worker_out[results]
    end
  end
  inputs = 0
  @equations.each_slice(4) do |list|
    input << list
    inputs += 1
  end
  inputs.times do
    results = output.pop
    true_sum += results[0]
    true_sum_concat += results[1]
  end
ensure
  stop[]
end
puts "Total calibration result: #{true_sum}" # Part 1
puts "Total calibration result with concatenation: #{true_sum_concat}" # Part 2
