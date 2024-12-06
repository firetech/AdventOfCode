require 'set'
require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@map = File.read(file).rstrip.split("\n")
@start = nil
@map.each_with_index do |line, y|
  x = line.index('^')
  if not x.nil?
    @start = [x, y]
    line[x] = '.'
    break
  end
end
raise 'No guard?!' if @start.nil?

# Part 1
dx, dy = [0, -1]
x, y = @start
@visited = Set[@start]
inside = true
while inside
  new_x = nil
  new_y = nil
  begin
    turning = false
    new_y = y + dy
    if new_y < 0 or new_y >= @map.length
      inside = false
      break
    end
    new_x = x + dx
    if new_x < 0 or new_x >= @map[new_y].length
      inside = false
      break
    end
    # Turning right:
    # 0, -1 => 1, 0
    # 1, 0 => 0, 1
    # 0, 1 => -1, 0
    # -1, 0 => 0, -1
    if @map[new_y][new_x] == '#'
      turning = true
      dx, dy = -dy, dx
    end
  end while turning
  break unless inside
  @visited << [new_x, new_y]
  x = new_x
  y = new_y
end
puts @visited.size
