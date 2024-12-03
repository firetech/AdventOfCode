require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'
#file = 'example2'

sum = 0 # Part 1
sum_do = 0 # Part 2
enabled = true # Part 2

File.read(file).rstrip.split("\n").each do |line|
  line.scan(/(do|don't)\(\)|mul\((\d{1,3}),(\d{1,3})\)/) do |op|
    case op[0]
    when 'do'
      enabled = true
    when 'don\'t'
      enabled = false
    else
      sum += op[1].to_i * op[2].to_i
      sum_do += op[1].to_i * op[2].to_i if enabled
    end
  end
end

puts "Sum of mul(): #{sum}" # Part 1
puts "Sum of mul() with do()/don't(): #{sum_do}" # Part 2

