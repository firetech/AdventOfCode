require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

blocks = File.read(file).rstrip.split("\n\n")

@list = []
blocks.each do |block_in|
  heights = []
  block = block_in.split("\n").map(&:chars).transpose
  block.each do |column|
    heights << column.count('#') - 1
  end
  case block.first.first
  when '#'
    type = :lock
  when '.'
    type = :key
  else
    raise "Unexpected character: '#{block.first.first}'"
  end
  @list << [type, heights]
end

count = 0
@list.combination(2) do |(type_a, heights_a), (type_b, heights_b)|
  next if type_a == type_b
  match = true
  heights_a.zip(heights_b) do |a, b|
    if a + b > 5
      match = false
      break
    end
  end
  count += 1 if match
end
puts "Unique key/lock pairs without overlap: #{count}"
