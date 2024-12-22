require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'
#file = 'example2'

@numbers = File.read(file).rstrip.split("\n").map(&:to_i)
#@numbers = [123]

def next_secret(num)
  num ^= num << 6 # * 64
  num &= 0xffffff
  num ^= num >> 5 # / 32
  num &= 0xffffff
  num ^= num << 11 # * 2048
  return num & 0xffffff
end

@sum2000 = 0 # Part 1
@prices = [] # Part 2
@numbers.each do |num|
  list = []
  2000.times do
    list << num % 10
    num = next_secret(num)
  end
  @sum2000 += num # Part 1

  # Part 2
  this_prices = {}
  list.each_with_index do |price, i|
    next if i < 4
    sequence = [
      list[i-3] - list[i-4],
      list[i-2] - list[i-3],
      list[i-1] - list[i-2],
      price - list[i-1],
    ]
    this_prices[sequence] = price unless this_prices.has_key?(sequence)
  end
  @prices << this_prices
end

# Part 1
puts "Sum of all 2000th secret numbers: #{@sum2000}"

# Part 2
best_total = 0
(-9..9).to_a.repeated_permutation(4) do |seq|
  total = @prices.filter_map { |p| p[seq] }.sum
  best_total = total if total > best_total
end
puts "Maximum number of bananas: #{best_total}"
