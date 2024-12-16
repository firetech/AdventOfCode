require 'set'
require_relative '../../lib/aoc'
require_relative '../../lib/priority_queue'

file = ARGV[0] || AOC.input_file()
#file = 'example1'
#file = 'example2'

@walls = Set[]
@start = nil
@end = nil
File.read(file).rstrip.split("\n").each_with_index do |line, y|
  line.each_char.with_index do |char, x|
    pos = Complex(x, y)
    case char
    when '#'
      @walls << pos
    when 'S'
      raise 'Ehm?' unless @start.nil?
      @start = pos
    when 'E'
      raise 'Ehm?' unless @end.nil?
      @end = pos
    when '.'
      # Do nothing
    else
      raise "Unexpected map character: '#{char}'"
    end
  end
end

start = [@start, (1+0i)]
cost = Hash.new(Float::INFINITY)
cost[start] = 0
path = {}
path[start] = Set[@start]
@best_cost = nil
@best_tiles = nil
queue = PriorityQueue.new
queue.push(start, 0)
until queue.empty?
  state = queue.pop_min
  pos, delta = state
  this_cost = cost[state]
  this_path = path[state]

  if pos == @end
    @best_cost = this_cost
    @best_tiles = this_path
    break
  end

  [
    [pos + delta, delta, this_cost + 1],
    [pos, delta * (0-1i), this_cost + 1000],
    [pos, delta * (0+1i), this_cost + 1000]
  ].each do |npos, ndelta, ncost|
    next if @walls.include?(npos)
    nstate = [npos, ndelta]
    current_cost = cost[nstate]
    if ncost < current_cost
      cost[nstate] = ncost
      path[nstate] = this_path + [npos]
      queue.push(nstate, ncost)
    elsif ncost == current_cost
      path[nstate].merge(this_path)
    end
  end
end

# Part 1
puts "Lowest possible score: #{@best_cost}"

# Part 2
puts "Tiles included in at least one best path: #{@best_tiles.count}"
