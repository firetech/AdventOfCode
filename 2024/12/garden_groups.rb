require 'set'
require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'
#file = 'example2'
#file = 'example3'
#file = 'example4'
#file = 'example5'

map = File.read(file).rstrip.split("\n")

Y_BITS = Math.log2(map.length).floor + 1
Y_MASK = (1 << Y_BITS) - 1
def to_pos(x, y)
  return nil if x < 0 or y < 0
  return x << Y_BITS | y
end
def from_pos(pos)
  return pos >> Y_BITS, pos & Y_MASK
end

@field = {}
map.each_with_index do |line, y|
  line.each_char.with_index do |plant, x|
    @field[to_pos(x, y)] = plant.to_sym
  end
end

DIRS = [
  [ 1,  0],
  [ 0,  1],
  [-1,  0],
  [ 0, -1]
]

# BFS/Flood Fill to find areas.
queue = [@field.keys.first]
visited = Set[queue.first]
@areas = {}
@pos2area = {}
next_area = 0
until queue.empty?
  pos = queue.shift

  plant = @field[pos]
  area = @pos2area[pos]
  if area.nil?
    area = @pos2area[pos] = next_area
    next_area += 1
    (@areas[area] ||= Set[]) << pos
  end

  x, y = from_pos(pos)
  DIRS.each do |dx, dy|
    npos = to_pos(x+dx, y+dy)
    nplant = @field[npos]
    next if nplant.nil?
    if nplant == plant
      narea = @pos2area[npos]
      # Adjacent plant belongs to same area as current plant
      if narea.nil?
        @pos2area[npos] = area
      elsif narea != area
        # Merge areas
        target, other = [area, narea].sort
        @areas[other].each { |apos| @pos2area[apos] = target }
        @areas[target] += @areas.delete(other)
        area = target
      end
      (@areas[area] ||= Set[]) << npos
    end
    next unless visited.add?(npos)
    queue << npos
  end
end

# Find perimeters and sides
perimeter_cost = 0 # Part 1
side_cost = 0 # Part 2
@areas.each_value do |plots|
  # Find boundaries (perimeters)
  area = plots.count
  boundaries = Array.new(DIRS.count) { Set[] }
  plots.each do |pos|
    x, y = from_pos(pos)
    DIRS.each_with_index do |(dx, dy), i|
      npos = to_pos(x+dx, y+dy)
      unless plots.include?(npos)
        boundaries[i] << pos
      end
    end
  end

  # Part 1
  perimeters = boundaries.map(&:count).sum
  perimeter_cost += area * perimeters

  # Part 2
  boundaries.zip(DIRS) do |list, (ddx, ddy)|
    # For each boundary, remove all adjacent boundaries in both directions.
    # This will only leave one boundary per side of fence.
    moves = [[-ddy.abs, -ddx.abs], [ddy.abs, ddx.abs]]
    list.each do |pos|
      moves.each do |dx, dy|
        x, y = from_pos(pos)
        begin
          x += dx
          y += dy
        end while list.delete?(to_pos(x, y))
      end
    end
  end

  sides = boundaries.map(&:count).sum
  side_cost += area * sides
end

# Part 1
puts "Fence cost (perimeters): #{perimeter_cost}"

# Part 2
puts "Fence cost (sides): #{side_cost}"

