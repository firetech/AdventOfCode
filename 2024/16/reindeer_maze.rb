require 'set'
require_relative '../../lib/aoc'
require_relative '../../lib/priority_queue'

file = ARGV[0] || AOC.input_file()
#file = 'example1'
#file = 'example2'

map_lines = File.read(file).rstrip.split("\n")
MAP_HEIGHT = map_lines.count
MAP_WIDTH = map_lines.first.length

X_BITS = Math.log2(MAP_WIDTH - 1).floor + 1
X_MASK = (1 << X_BITS) - 1
def to_pos(x, y)
  return y << X_BITS | x
end
def from_pos(pos)
  return pos & X_MASK, pos >> X_BITS
end

DIRS = [
  [ 1,  0],
  [ 0,  1],
  [-1,  0],
  [ 0, -1]
]
def to_state(pos, dir)
  return pos << 2 | dir
end
def from_state(state)
  return state >> 2, state & 0b11
end

@walls = Set[]
@start = nil
@end = nil
map_lines.each_with_index do |line, y|
  line.each_char.with_index do |char, x|
    pos = to_pos(x, y)
    case char
    when '#'
      @walls << pos
    when 'S'
      raise 'Ehm?' unless @start.nil?
      @start = pos
    when 'E'
      raise 'Ehm?' unless @end.nil?
      @end = pos
    when '.'
      # Do nothing
    else
      raise "Unexpected map character: '#{char}'"
    end
  end
end

start = to_state(@start, 0)
cost = Hash.new(Float::INFINITY)
cost[start] = 0
path = {}
path[start] = Set[@start]
@best_cost = nil
@best_tiles = nil
queue = PriorityQueue.new
queue.push(start, 0)
until queue.empty?
  state = queue.pop_min
  pos, dir = from_state(state)
  this_cost = cost[state]
  this_path = path[state]

  if pos == @end
    @best_cost = this_cost
    @best_tiles = this_path
    break
  end

  x, y = from_pos(pos)
  dx, dy = DIRS[dir]
  move_pos = to_pos(x+dx, y+dy)

  [
    [move_pos, dir, this_cost + 1],
    [pos, (dir + 1) % 4, this_cost + 1000],
    [pos, (dir - 1) % 4, this_cost + 1000]
  ].each do |npos, ndir, ncost|
    next if @walls.include?(npos)
    nstate = to_state(npos, ndir)
    current_cost = cost[nstate]
    if ncost < current_cost
      cost[nstate] = ncost
      path[nstate] = this_path + [npos]
      queue.push(nstate, ncost)
    elsif ncost == current_cost
      path[nstate].merge(this_path)
    end
  end
end

# Part 1
puts "Lowest possible score: #{@best_cost}"

# Part 2
puts "Tiles included in at least one best path: #{@best_tiles.count}"
