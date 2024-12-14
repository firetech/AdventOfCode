require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
@width = ARGV[1] || 101
@height = ARGV[2] || 103
#file = 'example1'; @width = 11; @height = 7

@robots = []
File.read(file).rstrip.split("\n").each do |line|
  case line
  when /\Ap=(\d+),(\d+) v=(-?\d+),(-?\d+)\z/
    @robots << {
      x: Regexp.last_match(1).to_i,
      y: Regexp.last_match(2).to_i,
      dx: Regexp.last_match(3).to_i,
      dy: Regexp.last_match(4).to_i
    }
  else
    raise "Malformed line: '#{line}'"
  end
end

@w_split = @width/2
@h_split = @height/2

def get_quadrant(x, y)
  if x < @w_split and y < @h_split
    return 0
  elsif x > @w_split and y < @h_split
    return 1
  elsif x < @w_split and y > @h_split
    return 2
  elsif x > @w_split and y > @h_split
    return 3
  end
  return nil
end


# Part 1
@quadrants = Array.new(4, 0)
@robots.each do |r|
  q = get_quadrant(
    (r[:x] + r[:dx] * 100) % @width,
    (r[:y] + r[:dy] * 100) % @height
  )
  @quadrants[q] += 1 unless q.nil?
end
puts "Safety factor after 100 seconds: #{@quadrants.inject(&:*)}"

# Part 2
# Easiest way => find minimum safety factor
cycles = 0
min_factor = Float::INFINITY
min_factor_cycles = nil
(@width * @height).times do
  cycles += 1
  quadrants = Array.new(4, 0)
  @robots.each do |r|
    r[:x] = (r[:x] + r[:dx]) % @width
    r[:y] = (r[:y] + r[:dy]) % @height
    q = get_quadrant(r[:x], r[:y])
    quadrants[q] += 1 unless q.nil?
  end
  factor = quadrants.inject(&:*)
  if factor < min_factor
    min_factor = factor
    min_factor_cycles = cycles
  end
end
puts "Easter egg seems to happen after #{min_factor_cycles} seconds"
