require 'set'
require_relative '../../lib/aoc'
require_relative '../../lib/multicore'

file = ARGV[0] || AOC.input_file()
#file = 'example1'
#file = 'example2'

@numbers = File.read(file).rstrip.split("\n").map(&:to_i)
#@numbers = [123]

PRUNE = 0xffffff
def next_secret(n)
  n = (n ^ (n << 6)) & PRUNE     # (n ^ (n * 64)) % 16777216
  n = (n ^ (n >> 5)) & PRUNE     # (n ^ (n / 32)) % 16777216
  return (n ^ (n << 11)) & PRUNE # (n ^ (n * 2048)) % 16777216
end

@sum2000 = 0 # Part 1
@totals = Hash.new(0) # Part 2

stop = nil
max_threads = [8, @numbers.length].min
begin
  input, output, stop, nrunners = Multicore.run(-max_threads) do |worker_in, worker_out|
    this_sum2000 = 0
    this_totals = Hash.new(0)
    worker_in[].each do |num|
      diffs = []
      seen = Set[]
      last = nil
      2000.times do |i|
        # Part 2
        price = num % 10
        unless last.nil?
          diffs << last - price
          if i >= 4
            key = diffs.hash
            this_totals[key] += price if seen.add?(key)
            diffs.shift
          end
        end
        last = price
        num = next_secret(num)
      end
      this_sum2000 += num
    end
    worker_out[[this_sum2000, this_totals]]
  end
  runner_slice = (@numbers.length / nrunners.to_f).ceil
  @numbers.each_slice(runner_slice) do |list|
    input << list
  end
  nrunners.times do
    this_sum2000, this_totals = output.pop
    # Part 1
    @sum2000 += this_sum2000

    # Part 2
    @totals.merge!(this_totals) { |_, v1, v2| v1 + v2 }
  end
ensure
  stop[]
end

# Part 1
puts "Sum of all 2000th secret numbers: #{@sum2000}"

# Part 2
puts "Maximum number of bananas: #{@totals.values.max}"
