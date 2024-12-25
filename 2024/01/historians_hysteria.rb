require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@left = []
@right = [] # Part 1
@rcount = Hash.new(0) # Part 2
File.read(file).rstrip.split("\n").each do |line|
  case line
  when /\A(\d+)\s+(\d+)\z/
    @left << Regexp.last_match(1).to_i
    right = Regexp.last_match(2).to_i
    @right << right
    @rcount[right] += 1
  else
    raise "Malformed line: '#{line}'"
  end
end

# Part 1
@dist = @left.sort.zip(@right.sort).sum { |l, r| (l - r).abs }
puts "Total distance: #{@dist}"

# Part 2
@similarity = @left.sum { |x| x * @rcount[x] }
puts "Similarity score: #{@similarity}"
