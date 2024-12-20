require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
@min_savings = (ARGV[1] || 100).to_i
#file = 'example1'; @min_savings = 50

map_lines = File.read(file).rstrip.split("\n")

MAX_STEPS = 20
Y_BITS = Math.log2(map_lines.count - 1 + MAX_STEPS).floor + 1
def to_pos(x, y)
  return (x << Y_BITS) + y
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
@dist = { @start => 0 }
until queue.empty?
  pos = queue.shift
  break if pos == @end

  ndist = @dist[pos] + 1
  [[0, -1], [0, 1], [-1, 0], [1, 0]].each do |dx, dy|
    npos = pos + to_pos(dx, dy)
    next if @walls[npos] or @dist[npos]
    @dist[npos] = ndist
    queue << npos
  end
end

# Find cheats with specified maximum (and minimum) path length
def num_cheats(max_steps, min_steps = 1)
  cheats = 0
  (-max_steps).upto(max_steps).each do |dx|
    max_dy = max_steps - dx.abs
    (-max_dy).upto(max_dy) do |dy|
      cheat_dist = dx.abs + dy.abs
      next if cheat_dist < min_steps
      dpos = to_pos(dx, dy)
      @dist.each do |pos, steps|
        nsteps = @dist[pos + dpos]
        next if nsteps.nil?
        cheats += 1 if nsteps - (steps + cheat_dist) >= @min_savings
      end
    end
  end
  return cheats
end

# Part 1
@cheats2 = num_cheats(2)
puts "#{@cheats2} possible 2-picosecond-cheats save more than #{@min_savings} picoseconds"

# Part 2
@cheats20 = @cheats2 + num_cheats(MAX_STEPS, 3)
puts "#{@cheats20} possible 20-picosecons-cheats save more than #{@min_savings} picoseconds"
