require 'set'
require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'
#file = 'example2'
#file = 'example3'
#file = 'example4'
#file = 'example5'

map = File.read(file).rstrip.split("\n")

# This works for negative coordinates, BUT ONLY if they're only ever used as
# delta values.
# I.e.
#   to_pos(3, 4) + to_pos(-2, -3) == to_pos(1, 1)
# but
#   from_pos(to_pos(-2, -3)) != [-2, -3]
Y_BITS = Math.log2(map.length).floor + 1
def to_pos(x, y)
  return (x << Y_BITS) + y
end

@field = {}
map.each_with_index do |line, y|
  line.each_char.with_index do |plant, x|
    @field[to_pos(x, y)] = plant.to_sym
  end
end

POS_DIRS = [
  to_pos(1, 0),
  to_pos(0, 1)
]
ALL_DIRS = POS_DIRS + [
  to_pos(-1,  0),
  to_pos( 0, -1)
]

# BFS/Flood Fill to find areas.
start = to_pos(0, 0)
queue = [start]
visited = Set[start]
@areas = {}
@pos2area = {}
next_area = 0
until queue.empty?
  pos = queue.shift

  plant = @field[pos]
  area = @pos2area[pos]
  if area.nil?
    area = @pos2area[pos] = (next_area += 1)
    @areas[area] = Set[pos]
  end

  POS_DIRS.each do |dpos|
    npos = pos + dpos
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
  ALL_DIRS.each do |dpos|
    dir_boundaries = Set[]
    plots.each do |pos|
      unless plots.include?(pos + dpos)
        dir_boundaries << pos
      end
    end
    boundaries << dir_boundaries
  end

  # Part 1
  perimeters = boundaries.map(&:count).sum
  perimeter_cost += area * perimeters

  # Part 2
  ndirs = ALL_DIRS.length
  boundaries.each_with_index do |list, i|
    # For each boundary, remove any adjacent boundaries next to it by walking in
    # negative and positive directions perpendicular to the boundary direction.
    # This will only leave one boundary per side of fence.
    dpos = ALL_DIRS[(i+1) % ndirs]
    list.each do |pos|
      npos = pos
      while list.delete?(npos += dpos); end
      npos = pos
      while list.delete?(npos -= dpos); end
    end
  end
  sides = boundaries.map(&:count).sum
  side_cost += area * sides
end

# Part 1
puts "Fence cost (perimeters): #{perimeter_cost}"

# Part 2
puts "Fence cost (sides): #{side_cost}"

