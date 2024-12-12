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

POS_DIRS = [
  [ 1,  0],
  [ 0,  1]
]
ALL_DIRS = POS_DIRS + [
  [-1,  0],
  [ 0, -1]
]

# BFS/Flood Fill to find areas.
queue = [to_pos(0, 0)]
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
    @areas[area] = Set[pos]
  end

  x, y = from_pos(pos)
  POS_DIRS.each do |dx, dy|
    npos = to_pos(x+dx, y+dy)
    nplant = @field[npos]
    next if nplant.nil?
    if nplant == plant
      # Adjacent plant is in same area as current plant
      narea = @pos2area[npos]
      if narea.nil?
        @pos2area[npos] = area
        @areas[area] << npos
      elsif narea != area
        # Merge areas
        @areas[area].each { |apos| @pos2area[apos] = narea }
        @areas[narea].merge(@areas.delete(area))
        area = narea
      end
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
  boundaries = []
  ALL_DIRS.each do |dx, dy|
    dir_boundaries = Set[]
    plots.each do |pos|
      x, y = from_pos(pos)
      unless plots.include?(to_pos(x+dx, y+dy))
        dir_boundaries << pos
      end
    end
    boundaries << dir_boundaries
  end

  # Part 1
  perimeters = boundaries.map(&:count).sum
  perimeter_cost += area * perimeters

  # Part 2
  boundaries.zip(ALL_DIRS) do |list, (ddx, ddy)|
    # For each boundary, remove any adjacent boundaries next to it.
    # This will only leave one boundary per side of fence.
    [
      # This makes us walk in negative and positive directions perpendicular to
      # the boundary direction
      [-ddy.abs, -ddx.abs],
      [ ddy.abs,  ddx.abs]
    ].each do |dx, dy|
      list.each do |pos|
        x, y = from_pos(pos)
        while list.delete?(to_pos(x += dx, y += dy)); end
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

