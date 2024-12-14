require_relative '../../lib/aoc'
require_relative '../../lib/aoc_math'

file = ARGV[0] || AOC.input_file()
@width = ARGV[1] || 101
@height = ARGV[2] || 103
#file = 'example1'; @width = 11; @height = 7

@robots = []
File.read(file).rstrip.split("\n").each do |line|
  case line
  when /\Ap=(\d+),(\d+) v=(-?\d+),(-?\d+)\z/
    @robots << {
      x: Regexp.last_match(1).to_i,
      y: Regexp.last_match(2).to_i,
      dx: Regexp.last_match(3).to_i,
      dy: Regexp.last_match(4).to_i
    }
  else
    raise "Malformed line: '#{line}'"
  end
end

@w_split = @width/2
@h_split = @height/2

# Part 1
quadrants = Array.new(4, 0)
@robots.each do |r|
  x = (r[:x] + r[:dx] * 100) % @width
  y = (r[:y] + r[:dy] * 100) % @height
  q = nil
  if x < @w_split and y < @h_split
    q = 0
  elsif x > @w_split and y < @h_split
    q = 1
  elsif x < @w_split and y > @h_split
    q = 2
  elsif x > @w_split and y > @h_split
    q = 3
  else
    next
  end
  quadrants[q] += 1
end
puts "Safety factor after 100 seconds: #{quadrants.inject(&:*)}"

# Part 2
# Find time with minimum variance in X and Y (individually)
cycles = [@width, @height]
min_vars = Array.new(2, Float::INFINITY)
min_var_times = Array.new(2)
cycles.max.times do |t|
  positions = Array.new(2) { [] }
  @robots.each do |r|
    positions[0] << (r[:x] + r[:dx] * t) % @width
    positions[1] << (r[:y] + r[:dy] * t) % @height
  end
  positions.each_with_index do |p, i|
    mean = p.sum.to_f / p.length
    # Variance is actually this value divided by the length, but since we
    # only want to find the minimum variance, that's an unnecessary step.
    var_sum = p.sum { |x| (x - mean)**2 }
    if var_sum < min_vars[i]
      min_vars[i] = var_sum
      min_var_times[i] = t
    end
  end
end
# The time when both of these happens at the same time can then be given by
# inputting these values into the Chinese Remainder Theorem.
min_var_time = AOCMath.chinese_remainder(cycles, min_var_times)
puts "Easter egg seems to happen after #{min_var_time} seconds"

# Uncomment to draw the easter egg
=begin
require 'set'
r_pos = Set[]
@robots.each do |r|
  x = (r[:x] + r[:dx] * min_var_time) % @width
  y = (r[:y] + r[:dy] * min_var_time) % @height
  r_pos << [x, y]
end
@height.times do |y|
  @width.times do |x|
    if r_pos.include?([x, y])
      print "\u2588"
    else
      print ' '
    end
  end
  puts
end
=end
