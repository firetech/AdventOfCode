require_relative '../../lib/aoc'
require_relative '../../lib/aoc_math'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

input = File.read(file).strip.split("\n")

timestamp = input.shift.to_i
lines = input.shift.split(',').map do |line|
  if line == 'x'
    nil
  else
    line.to_i
  end
end

#part 1
active_lines = lines.compact
min_wait = Float::INFINITY
best_line = nil
active_lines.each do |line|
  wait = line - timestamp % line
  if wait < min_wait
    min_wait = wait
    best_line = line
  end
end

puts "Wait time: #{min_wait}, Line: #{best_line}, Score: #{min_wait * best_line}"


#part 2


remainders = []
lines.each_with_index do |line, i|
  if not line.nil?
    remainders << line - i
  end
end

puts "Time of bus cascade: #{AOCMath.chinese_remainder(active_lines, remainders)}"
