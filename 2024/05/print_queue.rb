require 'set'
require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

rules, updates = File.read(file).rstrip.split("\n\n")

@rules = {}
rules.split("\n").each do |line|
  case line
  when /\A(\d+)\|(\d+)\z/
    before = Regexp.last_match(1).to_i
    after = Regexp.last_match(2).to_i
    @rules[before] ||= Set[]
    @rules[before] << after
  else
    raise "Malformed line: '#{line}'"
  end
end

@updates = []
updates.split("\n").each do |line|
  @updates << line.split(',').map(&:to_i)
end

@correct_updates = [] # Part 1
@incorrect_updates = [] # Part 2
@updates.each do |update|
  printed = Set[]
  correct = true
  update.each do |page|
    if printed.intersect?(@rules[page] || [])
      correct = false
      break
    end
    printed << page
  end
  if correct
    @correct_updates << update
  else
    @incorrect_updates << update
  end
end

# Part 1
middle_sum = @correct_updates.sum { |l| l[l.length/2] }
puts "Middle sum of correct updates: #{middle_sum}"

# Part 2
middle_sum_incorrect = 0
@incorrect_updates.each do |update|
  update.sort! do |a, b|
    if @rules.has_key?(a) and @rules[a].include?(b)
      -1
    elsif @rules.has_key?(b) and @rules[b].include?(a)
      1
    else
      0
    end
  end
  middle_sum_incorrect += update[update.length/2]
end
puts "Middle sum of fixed incorrect updates: #{middle_sum_incorrect}"
