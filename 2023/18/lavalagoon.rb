require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

DIR2DELTA = {
  'U' => [0, -1],
  'D' => [0,  1],
  'L' => [-1, 0],
  'R' => [ 1, 0]
}
HEX2DIR = { # For part 2
  '0' => 'R',
  '1' => 'D',
  '2' => 'L',
  '3' => 'U'
}
@steps1 = [] # Part 1
@steps2 = [] # Part 2
File.read(file).rstrip.split("\n").each do |line|
  case line
  when /\A(U|D|L|R) (\d+) \(\#([0-9a-f]{5})([0-3])\)\z/
    @steps1 << [
      *DIR2DELTA[Regexp.last_match(1)],
      Regexp.last_match(2).to_i
    ]
    @steps2 << [
      *DIR2DELTA[HEX2DIR[Regexp.last_match(4)]],
      Regexp.last_match(3).to_i(16)
    ]
  else
    raise "Malformed line: '#{line}'"
  end
end

def fill(instructions)
  x = 0
  y = 0
  vertices = [[x, y]]
  instructions.each do |dx, dy, count|
    x += dx * count
    y += dy * count
    vertices << [x, y]
  end
  raise 'Not a loop' if vertices.last != vertices.first
  # Area of irregular polygon:
  #   |x1y2 - y1x2 + x2y3 - y2x3 + ... + xny1 - ynx1| / 2
  # Perimeter is just pythagoras, but since all of our lines are horizontal or
  # vertical, we can simplify it.
  count = vertices.length
  area = 0
  perimeter = 0
  vertices.each_cons(2) do |(x1, y1), (x2, y2)|
    area += x1*y2 - x2*y1
    perimeter += ((x2-x1) + (y2-y1)).abs
  end
  return (area.abs / 2 + perimeter / 2 + 1)
end

# Part 1
puts "Cubic meters of lava in lagoon: #{fill(@steps1)}"

# Part 2
puts "Cubic meters of lava in lagoon (color fill): #{fill(@steps2)}"
