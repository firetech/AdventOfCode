require 'set'
require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
@max_coord = (ARGV[1] || 70).to_i
@part1_count = 1024
#file = 'example1'; @max_coord = 6; @part1_count = 12

def to_pos(x, y)
  return [x, y]
end
def from_pos(pos)
  return pos
end

@list = []
File.read(file).rstrip.split("\n").each do |line|
  valid = false
  case line
  when /\A(\d+),(\d+)\z/
    x = Regexp.last_match(1).to_i
    y = Regexp.last_match(2).to_i
    if x <= @max_coord and y <= @max_coord
      valid = true
      @list << to_pos(x, y)
    end
  end
  raise "Malformed line: '#{line}'" unless valid
end

def run(corrupted)
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
    [[0, -1], [0, 1], [-1, 0], [1, 0]].each do |dx, dy|
      nx = x + dx
      next unless range.include?(nx)
      ny = y + dy
      next unless range.include?(ny)
      npos = to_pos(nx, ny)
      next if corrupted.include?(npos)
      next if dist[npos] <= ndist
      dist[npos] = ndist
      queue << npos
    end
  end
  return nil
end

@corrupted = Set[]
count = 0
@list.each do |pos|
  @corrupted << pos
  count += 1
  next if count < @part1_count

  dist = run(@corrupted)
  if count == @part1_count
    # Part 1
    puts "Steps to exit: #{dist}"
  else
    # Part 2
    if dist.nil?
      puts "First byte blocking exit: #{from_pos(pos).join(',')}"
      break
    end
  end
end
