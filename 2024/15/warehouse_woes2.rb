require 'set'
require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'
#file = 'example2'
#file = 'example3'

map_input, @moves = File.read(file).rstrip.split("\n\n")

class Box
  attr_reader :width

  def initialize(map, pos, width = 1)
    @map = map
    @x, @y = pos
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
  def initialize(map, pos)
    super(map, pos, 1)
  end

  def gps
    return 0
  end
end


def print_map
  $map_height.times do |y|
    last_box = nil
    ($map_width * 2).times do |x|
      content = $map[[x, y]]
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

$map = {}
$map_width = map_input.index("\n")
$map_height = map_input.count("\n") + 1
$robot = nil
map_input.split("\n").each_with_index do |line, y|
  line.each_char.with_index do |char, x|
    pos = [x*2, y]
    case char
    when 'O'
      Box.new($map, pos, 2) # inputs itself into map
    when '@'
      if $robot.nil?
        $robot = Robot.new($map, pos) # inputs itself into map
      else
        raise 'Multiple robots?'
      end
    when '#'
      $map[pos] = :wall
      $map[[x*2 + 1, y]] = :wall
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
  $robot.move(dx, dy)
end

gps_sum = 0
counted = Set[]
$map.each_value do |content|
  if content.is_a?(Box)
    next if counted.include?(content)
    gps_sum += content.gps
    counted << content
  end
end
puts "Sum of GPS coordinates: #{gps_sum}"
#print_map
