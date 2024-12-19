require 'set'
require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

towels_in, patterns_in = File.read(file).rstrip.split("\n\n")

@towels = Set.new(towels_in.split(', '))
@patterns = patterns_in.split("\n")

@possible = 0 # Part 1
@ways = 0 # Part 2
patterns_in.split("\n").each do |pattern|
  len = pattern.length

  # pattern[0...i] is possible if pattern[0...j] is possible and pattern[j...i]
  # is an available towel.
  # The number of ways to form pattern[0...i] is the sum of ways to form
  # pattern[0...j] for j < i and where pattern[j...i] is an available towel.
  formations = Array.new(len+1, 0)
  formations[0] = 1
  1.upto(len) do |i|
    0.upto(i-1) do |j|
      formations[i] += formations[j] if @towels.include?(pattern[j...i])
    end
  end

  ways = formations[len]
  @possible += 1 if ways > 0 # Part 1
  @ways += ways # Part 2
end

# Part 1
puts "Possible patterns: #{@possible}"

# Part 2
puts "Sum of ways to create each pattern: #{@ways}"
