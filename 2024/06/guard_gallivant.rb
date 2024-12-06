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

DIR_TO_DXDY = [
  # Turning right:
  # 0, -1 => 1, 0
  # 1, 0 => 0, 1
  # 0, 1 => -1, 0
  # -1, 0 => 0, -1
  [0, -1],
  [1, 0],
  [0, 1],
  [-1, 0]
]

def walk(obstruct_x = nil, obstruct_y = nil)
  dir = 0
  x, y = @start
  visited = {}
  inside = true
  while inside
    pos = [x, y]
    visited[pos] ||= Set[]
    return nil if visited[pos].include?(dir)
    visited[pos] << dir

    new_x = nil
    new_y = nil
    begin
      dx, dy = DIR_TO_DXDY[dir]
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
      if @map[new_y][new_x] == '#' or
          (new_x == obstruct_x and new_y == obstruct_y)
        turning = true
        dir = (dir + 1) % DIR_TO_DXDY.length
      end
    end while turning
    x = new_x
    y = new_y
  end
  return visited
end

# Part 1
@visited = walk
puts "#{@visited.count} visited positions"

# Part 2
obstructions = 0
@visited.each_key do |x, y|
  if walk(x, y).nil?
    obstructions += 1
  end
end
puts "#{obstructions} possible obstructions cause a loop"
