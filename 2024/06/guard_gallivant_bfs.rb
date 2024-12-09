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

def to_pos(x, y)
  return x << 8 | y
end

def walk(obstructions = nil)
  queue = [[ *@start, 0, {}, nil ]]
  loops = 0
  until queue.empty?
    x, y, dir, visited, obstructed = queue.shift

    new_x = nil
    new_y = nil
    new_pos = nil
    inside = true
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
      new_pos = to_pos(new_x, new_y)
      if not obstructions.nil? and obstructed.nil? and
          new_pos == obstructions.first
        obstructions.shift
        queue << [x, y, dir, visited.transform_values(&:clone), new_pos]
      elsif @map[new_y][new_x] == '#' or new_pos == obstructed
        turning = true
        dir = (dir + 1) % DIR_TO_DXDY.length
        turned = true
      end
    end while turning

    pos = to_pos(x, y)
    visited[pos] ||= []
    if visited[pos].include?(dir)
      loops += 1
      next
    end
    visited[pos] << dir

    if inside
      queue << [new_x, new_y, dir, visited, obstructed]
    elsif obstructions.nil?
      return visited
    end
  end
  return loops
end

# Part 1
@visited = walk()
puts "#{@visited.count} visited positions"

# Part 2
@visited.delete(to_pos(*@start))
obstructions = walk(@visited.keys)
puts "#{obstructions} possible obstructions cause a loop"
