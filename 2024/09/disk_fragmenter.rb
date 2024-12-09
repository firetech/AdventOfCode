require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@map = File.read(file).strip.chars.map(&:to_i)

@disk = [] # Part 1
@blocks = {} # Part 2
@spaces = {} # Part 2
id = 0
@map.each_slice(2) do |file, free|
  @blocks[id] = [@disk.length, file]
  @disk.push(*([id] * file))
  if not free.nil? and free > 0
    @spaces[@disk.length] = free
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
@blocks.reverse_each do |id, (block_start, length)|
  space = nil
  @spaces.keys.sort.each do |start|
    break if start >= block_start
    if @spaces[start] >= length
      space = start
      break
    end
  end

  unless space.nil?
    @blocks[id][0] = space
    size = @spaces.delete(space)
    if size > length
      @spaces[space + length] = size - length
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
