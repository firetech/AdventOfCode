require 'set'
require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'
#file = 'example2'
#file = 'example3'

map_input, @moves = File.read(file).rstrip.split("\n\n")

class Box
  attr_reader :width

  def initialize(map, x, y, width = 1)
    @map = map
    @x = x
    @y = y
    @width = width

    @width.times do |w|
      @map[[@x+w, @y]] = self
    end
  end

  def can_move?(dx, dy)
    checked = Set[]
    @width.times do |w|
      neighbour = @map[[@x+w+dx, @y+dy]]
      case neighbour
      when self
        next
      when :wall
        return false
      when Robot
        raise 'Eh?!'
      when Box
        next if checked.include?(neighbour)
        checked << neighbour
        return false unless neighbour.can_move?(dx,dy)
      end
    end
    return true
  end

  def move(dx, dy)
    return false unless can_move?(dx, dy)
    moved = Set[]
    @width.times do |w|
      neighbour = @map[[@x+w+dx, @y+dy]]
      case neighbour
      when self
        next
      when Box
        next if moved.include?(neighbour)
        moved << neighbour
        neighbour.move(dx, dy)
      end
      raise 'Hmm...' if @map.delete([@x+w, @y]) != self
    end
    # If we move ourselves in the map in the loop above, we'll get overwritten
    # by ourselves when moving right...
    @width.times do |w|
      @map[[@x+w+dx, @y+dy]] = self
    end
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
  $map_height.times do |y|
    last_box = nil
    ($map_width * 2*i).times do |x|
      content = $map[i][[x, y]]
      case content
      when :wall
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
      $map[0][[x, y]] = :wall

      # Part 2
      $map[1][[x*2, y]] = :wall
      $map[1][[x*2 + 1, y]] = :wall
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
