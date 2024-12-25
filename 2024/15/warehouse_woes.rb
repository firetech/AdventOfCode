require 'set'
require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'
#file = 'example2'
#file = 'example3'

map_input, @moves = File.read(file).rstrip.split("\n\n")

MAP_WIDTH = map_input.index("\n")
MAP_HEIGHT = map_input.count("\n") + 1

Y_BITS = Math.log2(MAP_HEIGHT).floor + 1
def to_pos(x, y)
  return x << Y_BITS | y
end

class Box
  attr_reader :width

  def initialize(map, x, y, width = 1)
    @map = map
    @x = x
    @y = y
    @width = width

    @width.times do |w|
      @map[to_pos(@x+w, @y)] = self
    end
  end

  def can_move?(dx, dy, checked = [])
    @width.times do |w|
      neighbour = @map[to_pos(@x+w+dx, @y+dy)]
      case neighbour
      when self
        next
      when false
        return false
      when Robot
        raise 'Eh?!'
      when Box
        unless checked.include?(neighbour)
          checked << neighbour
          return false unless neighbour.can_move?(dx, dy, checked)
        end
      end
    end
    return true
  end

  def move(dx, dy, moved = [])
    return false unless can_move?(dx, dy)
    new_pos = []
    @width.times do |w|
      npos = to_pos(@x+w+dx, @y+dy)
      neighbour = @map[npos]
      case neighbour
      when self
        # Do nothing
      when Box
        unless moved.include?(neighbour)
          moved << neighbour
          neighbour.move(dx, dy, moved)
        end
      end
      old_content = @map.delete(to_pos(@x+w, @y))
      raise 'Hmm...' if old_content != self
      new_pos << npos
    end
    # If we put each part in the new place in the map in the loop above, the
    # right part of the box will drop the freshly moved left part from the map
    # when moving right...
    new_pos.each { |pos| @map[pos] = self }
    @x += dx
    @y += dy
    return true
  end

  def gps
    return @y * 100 + @x
  end
end


class Robot < Box
  def initialize(map, x, y)
    super(map, x, y, 1)
  end
end


def print_map(i)
  MAP_HEIGHT.times do |y|
    last_box = nil
    (MAP_WIDTH * 2*i).times do |x|
      content = $map[i][to_pos(x, y)]
      case content
      when false
        print '#'
      when Robot
        print '@'
      when Box
        if content.width == 1
          print 'O'
        elsif last_box == content
          print ']'
        else
          print '['
        end
        last_box = content
      else
        print ' '
      end
    end
    puts
  end
end

$map = [{}, {}]
$boxes = [[], []]
$map_width = map_input.index("\n")
$map_height = map_input.count("\n") + 1
$robot = nil
map_input.split("\n").each_with_index do |line, y|
  line.each_char.with_index do |char, x|
    case char
    when 'O'
      # Boxes input themself into their map
      $boxes[0] << Box.new($map[0], x, y) # Part 1
      $boxes[1] << Box.new($map[1], x*2, y, 2) # Part 2
    when '@'
      if $robot.nil?
        # Robots input themself into their map
        $robot = [
          Robot.new($map[0], x, y), # Part 1
          Robot.new($map[1], x*2, y) # Part 2
        ]
      else
        raise 'Multiple robots?!'
      end
    when '#'
      # Part 1
      $map[0][to_pos(x, y)] = false

      # Part 2
      $map[1][to_pos(x*2, y)] = false
      $map[1][to_pos(x*2 + 1, y)] = false
    end
  end
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
  $robot.each { |r| r.move(dx, dy) }
end

# Part 1
puts "Sum of GPS coordinates: #{$boxes[0].sum(&:gps)}"
#print_map(0)

# Part 2
puts "Sum of GPS coordinates (wide map): #{$boxes[1].sum(&:gps)}"
#print_map(1)
