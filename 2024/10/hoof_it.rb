require 'set'
require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

map_in = File.read(file).rstrip.split("\n")
MAP_HEIGHT = map_in.length

# This works for negative coordinates, BUT ONLY if they're only ever used as
# delta values.
# I.e.
#   to_pos(3, 4) + to_pos(-2, -3) == to_pos(1, 1)
# but
#   from_pos(to_pos(-2, -3)) != [-2, -3]
Y_BITS = Math.log2(MAP_HEIGHT-1).floor + 1
def to_pos(x, y)
  return (x << Y_BITS) + y
end

DIRS = [
  to_pos( 1,  0),
  to_pos( 0, -1),
  to_pos(-1,  0),
  to_pos( 0,  1)
]

@heads = []
@map = {}
map_in.each_with_index do |line, y|
  line.each_char.with_index do |val, x|
    val_i = val.to_i
    pos = to_pos(x, y)
    @map[pos] = val_i
    @heads << pos if val_i == 0
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
      nheight = height + 1
      DIRS.each do |dpos|
        npos = pos + dpos
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
