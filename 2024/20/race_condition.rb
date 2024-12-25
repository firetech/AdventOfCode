require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
@min_savings = (ARGV[1] || 100).to_i
#file = 'example1'; @min_savings = 50

MAX_STEPS_1 = 2 # Part 1
MAX_STEPS_2 = 20 # Part 2
MAX_STEPS = [MAX_STEPS_1, MAX_STEPS_2].max

map_lines = File.read(file).rstrip.split("\n")

# This works for negative coordinates, BUT ONLY if they're only ever used as
# delta values.
# I.e.
#   to_pos(3, 4) + to_pos(-2, -3) == to_pos(1, 1)
# but
#   from_pos(to_pos(-2, -3)) != [-2, -3]
Y_BITS = Math.log2(map_lines.count - 1).floor + 1
Y_MASK = (1 << Y_BITS) - 1
def to_pos(x, y)
  return (x << Y_BITS) + y
end
def manhattan(p1, p2)
  return ((p2 >> Y_BITS) - (p1 >> Y_BITS)).abs +
      ((p2 & Y_MASK) - (p1 & Y_MASK)).abs
end

@start = nil
@end = nil
@walls = {}
map_lines.each_with_index do |line, y|
  line.each_char.with_index do |char, x|
    pos = to_pos(x, y)
    case char
    when '#'
      @walls[pos] = true
    when 'S'
      raise 'Multiple starts?' unless @start.nil?
      @start = pos
    when 'E'
      raise 'Multiple ends?' unless @end.nil?
      @end = pos
    when '.'
      # Do nothing
    else
      raise "Unknown map character: '#{char}'"
    end
  end
end

# Find base (cheat-less) path
queue = [@start]
from = { @start => nil }
until queue.empty?
  pos = queue.shift
  break if pos == @end

  [[0, -1], [0, 1], [-1, 0], [1, 0]].each do |dx, dy|
    npos = pos + to_pos(dx, dy)
    next if @walls[npos] or from.has_key?(npos)
    from[npos] = pos
    queue << npos
  end
end
@path = []
node = @end
until node.nil?
  @path.unshift(node)
  node = from[node]
end

# Count the number of possible cheat paths
len = @path.length
max_check = len - @min_savings
@cheats = [0, 0]
@path.each_with_index do |pos, steps|
  break if steps > max_check
  nsteps = steps + @min_savings
  while nsteps < len
    dist = manhattan(pos, @path[nsteps])
    if dist > MAX_STEPS
      # If we end up on a point further away than the maximum number of steps,
      # we can skip ahead the minimum number of steps needed to get from that
      # point to being back inside out cheatable radius.
      nsteps += dist - MAX_STEPS
    else
      if nsteps - (steps + dist) >= @min_savings
        @cheats[0] += 1 if dist <= MAX_STEPS_1 # Part 1
        @cheats[1] += 1 if dist <= MAX_STEPS_2 # Part 2
      end
      nsteps += 1
    end
  end
end

# Part 1
puts "#{@cheats[0]} possible #{MAX_STEPS_1}-picosecond-cheats save more than " \
     "#{@min_savings} picoseconds"

# Part 2
puts "#{@cheats[1]} possible #{MAX_STEPS_2}-picosecons-cheats save more than " \
     "#{@min_savings} picoseconds"
