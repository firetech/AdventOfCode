require 'set'
require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

X_BITS = 8
X_MASK = (1 << X_BITS) - 1
def to_pos(x, y)
  return y << X_BITS | x
end
def from_pos(pos)
  return pos & X_MASK, pos >> X_BITS
end

@heads = []
@map = {}
File.read(file).rstrip.split("\n").each_with_index do |line, y|
  line.chars.each_with_index do |val, x|
    val_i = val.to_i
    pos = to_pos(x, y)
    @map[pos] = val_i
    if val_i == 0
      @heads << pos
    end
  end
end

@peak_sum = 0 # Part 1
@path_sum = 0 # Part 2
@heads.each do |head_pos|
  stack = [head_pos]
  peaks = Set[]
  until stack.empty?
    pos = stack.pop
    height = @map[pos]

    if height == 9
      @peak_sum += 1 if peaks.add?(pos) # Part 1
      @path_sum += 1 # Part 2
    else
      x, y = from_pos(pos)
      nheight = height + 1
      [
        [ 1,  0],
        [ 0, -1],
        [-1,  0],
        [ 0,  1]
      ].each do |dx, dy|
        npos = to_pos(x + dx, y + dy)
        next if @map[npos] != nheight
        stack << npos
      end
    end
  end
end

# Part 1
puts "Sum of trailhead peak scores: #{@peak_sum}"

# Part 2
puts "Sum of trailhead path scores: #{@path_sum}"
