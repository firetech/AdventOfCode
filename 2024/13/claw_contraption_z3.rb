require 'z3'
require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@machines = []
File.read(file).rstrip.split("\n\n").each do |block|
  machine = {}
  block.split("\n").each do |line|
    case line
    when /\AButton ([AB]): X\+(\d+), Y\+(\d+)\z/
      machine[Regexp.last_match(1).downcase.to_sym] = [
        Regexp.last_match(2).to_i,
        Regexp.last_match(3).to_i
      ]
    when /\APrize: X=(\d+), Y=(\d+)\z/
      machine[:out] = [
        Regexp.last_match(1).to_i,
        Regexp.last_match(2).to_i
      ]
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
    solver = Z3::Optimize.new
    a_push = Z3.Int('a_push')
    b_push = Z3.Int('b_push')
    m[:out].zip(m[:a], m[:b]) do |out, a, b|
      solver.assert(a * a_push + b * b_push == out + offset)
    end
    solver.minimize(a_push * 3 + b_push)
    next unless solver.satisfiable?
    sum[i] += solver.model[a_push].to_i * 3 + solver.model[b_push].to_i
  end
end

# Part 1
puts "Fewest tokens to spend: #{sum[0]}"

# Part 2
puts "Fewest tokens to spend (with corrected units): #{sum[1]}"
