require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@map = File.read(file).strip.chars.map(&:to_i)

@disk = [] # Part 1
@blocks = {} # Part 2
@spaces = [] # Part 2
id = 0
@map.each_slice(2) do |file, free|
  @blocks[id] = [@disk.length, file]
  @disk.push(*([id] * file))
  if not free.nil? and free > 0
    @spaces << [@disk.length, free]
    @disk.push(*([nil] * free))
  end
  id += 1
end

# Part 1
@disk.each_index do |i|
  while @disk[i].nil?
    new_data = @disk.pop
    @disk[i] = new_data unless new_data.nil?
    break if i == @disk.length
  end
end
checksum1 = 0
@disk.each_with_index { |x, i| checksum1 += x * i }
puts "Checksum after compaction: #{checksum1}"

# Part 2
@blocks.reverse_each do |id, (block_start, block_length)|
  space = nil
  @spaces.each_with_index do |(space_start, space_length), i|
    break if space_start >= block_start
    if space_length >= block_length
      space = i
      break
    end
  end

  unless space.nil?
    space_start, space_length = @spaces[space]
    @blocks[id][0] = space_start
    if block_length == space_length
      @spaces.delete_at(space)
    else
      @spaces[space][0] += block_length
      @spaces[space][1] -= block_length
    end
  end
end

checksum2 = 0
@blocks.each do |id, (start, length)|
  length.times do |i|
    checksum2 += id * (start + i)
  end
end
puts "Checksum after defragmentation: #{checksum2}"
