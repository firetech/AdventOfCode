require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'
#file = 'example2'

map_input, @moves = File.read(file).rstrip.split("\n\n")

def to_pos(x, y)
  return [x, y]
end
def from_pos(pos)
  return pos
end

@map = {}
@robot = nil
map_input.split("\n").each_with_index do |line, y|
  line.each_char.with_index do |char, x|
    pos = to_pos(x, y)
    case char
    when 'O'
      @map[pos] = :box
    when '@'
      if @robot.nil?
        @robot = pos
        @map[pos] = :robot
      else
        raise 'Multiple robots?'
      end
    when '#'
      @map[pos] = :wall
    end
  end
end


def move(pos, dx, dy)
  x, y = from_pos(pos)
  npos = to_pos(x+dx, y+dy)
  case @map[npos]
  when :box
    return false unless move(npos, dx, dy)
  when :wall
    return false
  when :robot
    raise 'Eh?!'
  end
  @map[npos] = @map.delete(pos)
  return npos
end

@moves.each_char do |char|
  dx = 0
  dy = 0
  case char
  when "\n"
    next
  when '^'
    dy = -1
  when 'v'
    dy = 1
  when '<'
    dx = -1
  when '>'
    dx = 1
  else
    raise "Unknown move char '#{char}'"
  end
  new_pos = move(@robot, dx, dy)
  @robot = new_pos if new_pos
end

gps_sum = 0
@map.each do |pos, content|
  next unless content == :box
  x, y = from_pos(pos)
  gps_sum += y * 100 + x
end
puts "Sum of GPS coordinates: #{gps_sum}"
