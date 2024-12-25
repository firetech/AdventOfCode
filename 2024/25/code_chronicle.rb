require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

blocks = File.read(file).rstrip.split("\n\n")

@locks = []
@keys = []
blocks.each do |block|
  heights = []
  block.split("\n").map(&:chars).transpose.each do |column|
    heights << column.count('#') - 1
  end
  case block[0]
  when '#'
    @locks << heights
  when '.'
    @keys << heights
  else
    raise "Unexpected character: '#{block[0]}'"
  end
end

count = 0
@locks.each do |lock|
  @keys.each do |key|
    match = true
    key.zip(lock) do |k, l|
      if k + l > 5
        match = false
        break
      end
    end
    count += 1 if match
  end
end
puts "Unique key/lock pairs without overlap: #{count}"
