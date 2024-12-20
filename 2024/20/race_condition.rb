require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
@min_savings = (ARGV[1] || 100).to_i
#file = 'example1'; @min_savings = 50

def to_pos(x, y)
  return [x, y]
end
def from_pos(pos)
  return pos
end

@start = nil
@end = nil
@walls = {}
File.read(file).rstrip.split("\n").each_with_index do |line, y|
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

  x, y = from_pos(pos)
  ndist = @dist[pos] + 1
  [[0, -1], [0, 1], [-1, 0], [1, 0]].each do |dx, dy|
    nx = x + dx
    ny = y + dy
    npos = to_pos(nx, ny)
    next if @walls[npos] or @dist[npos]
    @dist[npos] = ndist
    queue << npos
  end
end

# Find cheats with specified max path length
def num_cheats(max_steps)
  cheats = 0
  @dist.each do |pos, steps|
    x, y = from_pos(pos)
    (-max_steps).upto(max_steps) do |dy|
      (-max_steps).upto(max_steps) do |dx|
        cheat_dist = dx.abs + dy.abs
        next if cheat_dist < 1 or cheat_dist > max_steps
        npos = to_pos(x + dx, y + dy)
        nsteps = @dist[npos]
        next if nsteps.nil? or nsteps <= steps + cheat_dist
        cheat_save = nsteps - (steps + cheat_dist)
        cheats += 1 if cheat_save >= @min_savings
      end
    end
  end
  return cheats
end

# Part 1
puts "#{num_cheats(2)} possible 2-picosecond-cheats save more than #{@min_savings} picoseconds"

# Part 2
puts "#{num_cheats(20)} possible 20-picosecons-cheats save more than #{@min_savings} picoseconds"
