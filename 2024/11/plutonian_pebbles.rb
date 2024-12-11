require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@stones = File.read(file).rstrip.split(/\s+/).map(&:to_i)

def blink(stones)
  new_stones = []
  stones.each do |stone|
    if stone == 0
      new_stones << 1
    else
      digits = Math.log10(stone).floor + 1
      if digits % 2 == 0
        div = 10**(digits/2)
        new_stones << stone / div
        new_stones << stone % div
      else
        new_stones << stone * 2024
      end
    end
  end
  return new_stones
end

stones = @stones
25.times { stones = blink(stones) }

pp stones.count
