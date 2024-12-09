require_relative '../../lib/aoc'

input = ARGV[0] || AOC.input()
#input = '2333133121414131402'

@map = input.strip.chars.map(&:to_i)

@part1_disk = []
@part2_blocks = {}
@part2_spaces = {}
id = 0
@map.each_slice(2) do |file, free|
  @part2_blocks[id] = [@part1_disk.length, file]
  @part1_disk.push(*([id] * file))
  unless free.nil?
    @part2_spaces[@part1_disk.length] = free
    @part1_disk.push(*([nil] * free))
  end
  id += 1
end



# Part 1
@part1_disk.each_index do |i|
  while i < @part1_disk.length and @part1_disk[i].nil?
    new_data = @part1_disk.pop
    @part1_disk[i] = new_data unless new_data.nil?
    break if i == @part1_disk.length
  end
end
checksum1 = 0
@part1_disk.each_with_index { |x, i| checksum1 += x * i }
puts "Checksum after compaction: #{checksum1}"

# Part 2
@part2_blocks.each_key.reverse_each do |id|
  i, length = @part2_blocks[id]
  space = nil
  @part2_spaces.keys.sort.each do |start|
    break if start >= i
    if @part2_spaces[start] >= length
      space = start
      break
    end
  end

  unless space.nil?
    @part2_blocks[id][0] = space
    size = @part2_spaces.delete(space)
    if size > length
      @part2_spaces[space + length] = size - length
    end
  end
end

checksum2 = 0
@part2_blocks.each do |id, (start, length)|
  length.times do |i|
    checksum2 += id * (start + i)
  end
end
puts "Checksum after defragmentation: #{checksum2}"
