require 'set'
require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'
#file = 'example2'
#file = 'example3'
#file = 'example4'
#file = 'example5'

@field = {}
File.read(file).rstrip.split("\n").each_with_index do |line, y|
  line.each_char.with_index do |plant, x|
    @field[[x, y]] = plant.to_sym
  end
end

DIRS = [
  [ 1,  0],
  [ 0,  1],
  [-1,  0],
  [ 0, -1]
]

queue = [[0,0]]
visited = Set[]
@areas = {}
@pos2area = {}
next_area = 0
until queue.empty?
  pos = queue.shift
  next if visited.include?(pos)
  visited << pos

  plant = @field[pos]
  area = @pos2area[pos]
  if area.nil?
    area = @pos2area[pos] = next_area
    next_area += 1
  end
  (@areas[area] ||= Set[]) << pos

  x, y = pos
  DIRS.each do |dx, dy|
    npos = [x+dx, y+dy]
    nplant = @field[npos]
    next if nplant.nil?
    narea = @pos2area[npos]
    if nplant == plant
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
    queue << npos
  end
end

perimeter_cost = 0 # Part 1
side_cost = 0 # Part 2
@areas.each_value do |plots|
  area = plots.count
  boundaries = {}
  plots.each do |pos|
    x, y = pos
    DIRS.each do |dir|
      dx, dy = dir
      nx = x + dx
      ny = y + dy
      npos = [nx, ny]
      unless plots.include?(npos)
        (boundaries[dir] ||= Set[]) << npos
      end
    end
  end

  # Part 1
  perimeters = boundaries.values.map(&:count).sum
  perimeter_cost += area * perimeters

  # Part 2
  boundaries.each do |(ddx, ddy), list|
    moves = [[-ddy.abs, -ddx.abs], [ddy.abs, ddx.abs]]
    list.each do |pos|
      x, y = pos
      moves.each do |dx, dy|
        nx = x
        ny = y
        begin
          nx += dx
          ny += dy
          npos = [nx, ny]
        end while list.delete?(npos)
      end
    end
  end

  sides = boundaries.values.map(&:count).sum
  side_cost += area * sides
end

# Part 1
puts "Fence cost (perimeters): #{perimeter_cost}"

# Part 2
puts "Fence cost (sides): #{side_cost}"

