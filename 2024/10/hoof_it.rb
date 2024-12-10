require 'set'
require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@heads = []
@map = File.read(file).rstrip.split("\n").map.with_index do |line, y|
  line.chars.map(&:to_i).each_with_index do |val, x|
    if val == 0
      @heads << [x, y]
    end
  end # returns line.chars.map(&:to_i)
end

@peak_sum = 0 # Part 1
@path_sum = 0 # Part 2
@heads.each do |x, y|
  stack = [[x, y, 0]]
  peaks = Set[]
  until stack.empty?
    x, y, height = stack.pop
    if height == 9
      @peak_sum += 1 if peaks.add?([x, y]) # Part 1
      @path_sum += 1 # Part 2
    else
      nheight = height + 1
      [
        [ 1,  0],
        [ 0, -1],
        [-1,  0],
        [ 0,  1]
      ].each do |dx, dy|
        ny = y + dy
        next if ny < 0 or @map[ny].nil?
        nx = x + dx
        next if nx < 0 or @map[ny][nx].nil?
        next if @map[ny][nx] != nheight
        stack << [nx, ny, nheight]
      end
    end
  end
end

# Part 1
puts "Sum of trailhead peak scores: #{@peak_sum}"

# Part 2
puts "Sum of trailhead path scores: #{@path_sum}"
