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


# Part 1
true_sum = 0
@equations.each do |result, operands|
  [:+, :*].repeated_permutation(operands.count - 1) do |operators|
    value = operands.first
    operators.each_with_index do |op, i|
      value = value.send(op, operands[i+1])
      break if value > result
    end
    if value == result
      true_sum += result
      break
    end
  end
end

puts "Total calibration result: #{true_sum}"

# Part 2
true_sum_concat = 0
@equations.each do |result, operands|
  [:+, :*, :join].repeated_permutation(operands.count - 1) do |operators|
    value = operands.first
    operators.each_with_index do |op, i|
      if op == :join
        value = "#{value}#{operands[i+1]}".to_i
      else
        value = value.send(op, operands[i+1])
      end
      break if value > result
    end
    if value == result
      true_sum_concat += result
      break
    end
  end
end

puts "Total calibration result with concatenation: #{true_sum_concat}"
