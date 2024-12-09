require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@map = File.read(file).strip.chars.map(&:to_i)

@disk = []
id = 0
@map.each_slice(2) do |file, free|
  @disk.push(*([id] * file))
  @disk.push(*([nil] * free)) unless free.nil?
  id += 1
end

@disk.each_index do |i|
  while i < @disk.length and @disk[i].nil?
    new_data = @disk.pop
    @disk[i] = new_data unless new_data.nil?
    break if i == @disk.length
  end
end

checksum = 0
@disk.each_with_index { |x, i| checksum += x * i }
pp checksum
