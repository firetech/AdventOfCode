require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@counts = Hash.new(0)
File.read(file).rstrip.split(/\s+/).each do |num|
  @counts[num.to_i] += 1
end


def blink(counts)
  new_counts = Hash.new(0)
  @counts.each do |num, count|
    if num == 0
      new_counts[1] += count
    else
      digits = Math.log10(num).floor + 1
      if digits % 2 == 0
        div = 10**(digits/2)
        new_counts[num / div] += count
        new_counts[num % div] += count
      else
        new_counts[num * 2024] += count
      end
    end
  end
  return new_counts
end

# Part 1
25.times { @counts = blink(@counts) }
puts "Number of stones after 25 blinks: #{@counts.values.sum}"

# Part 2
50.times { @counts = blink(@counts) }
puts "Number of stones after 75 blinks: #{@counts.values.sum}"
