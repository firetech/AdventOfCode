require 'set'
require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
@max_coord = (ARGV[1] || 70).to_i
@part1_count = 1024
#file = 'example1'; @max_coord = 6; @part1_count = 12

Y_BITS = Math.log2(@max_coord).floor + 1
Y_MASK = (1 << Y_BITS) - 1
def to_pos(x, y)
  return x << Y_BITS | y
end
def from_pos(pos)
  return pos >> Y_BITS, pos & Y_MASK
end

DIRS = [[0, -1], [0, 1], [-1, 0], [1, 0]]

@list = Hash.new(Float::INFINITY)
File.read(file).rstrip.split("\n").each_with_index do |line, n|
  valid = false
  case line
  when /\A(\d+),(\d+)\z/
    x = Regexp.last_match(1).to_i
    y = Regexp.last_match(2).to_i
    if x <= @max_coord and y <= @max_coord
      valid = true
      @list[to_pos(x, y)] = n
      @list[:"block#{n}"] = [x, y]
    end
  end
  raise "Malformed line: '#{line}'" unless valid
end

def run(num_blocks)
  start = to_pos(0, 0)
  target = to_pos(@max_coord, @max_coord)
  range = 0..@max_coord
  dist = Hash.new(Float::INFINITY)
  dist[start] = 0
  queue = [start]
  until queue.empty?
    pos = queue.shift
    this_dist = dist[pos]

    if pos == target
      return this_dist
    end

    x, y = from_pos(pos)
    ndist = this_dist + 1
    DIRS.each do |dx, dy|
      nx = x + dx
      next unless range.include?(nx)
      ny = y + dy
      next unless range.include?(ny)
      npos = to_pos(nx, ny)
      next if @list[npos] < num_blocks
      next if dist[npos] <= ndist
      dist[npos] = ndist
      queue << npos
    end
  end
  return nil
end

# Part 1
puts "Steps to exit: #{run(@part1_count)}"

# Part 2
first_block_length = ((@part1_count+1)..@list.length).bsearch do |num_blocks|
  run(num_blocks).nil?
end
first_block = @list[:"block#{first_block_length - 1}"].join(',')
puts "First byte blocking exit: #{first_block}"
