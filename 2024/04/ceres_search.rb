require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

def key(x, y)
  return y << 8 | x
end

@xs = [] # Part 1
@as = [] # Part 2
@map = {}
File.read(file).rstrip.split("\n").each_with_index do |line, y|
  line.each_char.with_index do |c, x|
    @map[key(x, y)] = c
    @xs << [x, y] if c == 'X'
    @as << [x, y] if c == 'A'
  end
end

# Part 1
xmas_count = 0
@xs.each do |x, y|
  checks = Array.new(8, true)
  %w(M A S).each_with_index do |c, i|
    o = i + 1
    checks[0] = (c == @map[key(x+o, y  )]) if checks[0] # Right
    checks[1] = (c == @map[key(x+o, y-o)]) if checks[1] # Up Right
    checks[2] = (c == @map[key(x  , y-o)]) if checks[2] # Up
    checks[3] = (c == @map[key(x-o, y-o)]) if checks[3] # Up Left
    checks[4] = (c == @map[key(x-o, y  )]) if checks[4] # Left
    checks[5] = (c == @map[key(x-o, y+o)]) if checks[5] # Down Left
    checks[6] = (c == @map[key(x  , y+o)]) if checks[6] # Down
    checks[7] = (c == @map[key(x+o, y+o)]) if checks[7] # Down Right
  end
  xmas_count += checks.count(true)
end

puts "XMAS appearances: #{xmas_count}"

# Part 2
MS = %w(MS SM)
mas_count = 0
@as.each do |x, y|
  if MS.include?([@map[key(x-1, y-1)], @map[key(x+1, y+1)]].join) and
      MS.include?([@map[key(x+1, y-1)], @map[key(x-1, y+1)]].join)
    mas_count += 1
  end
end

puts "X-MAS appearances: #{mas_count}"
