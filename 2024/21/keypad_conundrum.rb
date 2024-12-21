require 'set'
require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

def to_pos(x, y)
  return Complex(x, y)
end
def from_pos(pos)
  return pos.real, pos.imag
end

KEYPAD = {
  7 => to_pos(0, 0),
  8 => to_pos(1, 0),
  9 => to_pos(2, 0),

  4 => to_pos(0, 1),
  5 => to_pos(1, 1),
  6 => to_pos(2, 1),

  1 => to_pos(0, 2),
  2 => to_pos(1, 2),
  3 => to_pos(2, 2),

  0 => to_pos(1, 3),
  :A => to_pos(2, 3)
}
KEYPAD[:valid] = Set.new(KEYPAD.values)

DIRPAD = {
  to_pos(0, -1) => to_pos(1, 0), # ^, Up
  :A            => to_pos(2, 0),

  to_pos(-1, 0) => to_pos(0, 1), # <, Left
  to_pos(0, 1) => to_pos(1, 1),  # v, Down
  to_pos(1, 0) => to_pos(2, 1)   # >, Right
}
DIRPAD[:valid] = Set.new(DIRPAD.values)

@list = File.read(file).rstrip.split("\n").map do |line|
  [
    line.to_i,
    line.each_char.map do |char|
      case char
      when '0'..'9'
        char.to_i
      when 'A'
        :A
      else
        raise "Malformed line: '#{line}'"
      end
    end
  ]
end

# Yield all possible paths from one key to another.
@key_to_key_cache = {}
def key_to_key_paths(pad, from, to)
  cache_key = [pad == KEYPAD, from, to].hash
  paths = @key_to_key_cache[cache_key]
  if paths.nil?
    target = pad[to]
    tx, ty = from_pos(target)
    paths = []
    queue = [[pad[from], []]]
    until queue.empty?
      pos, path = queue.shift

      if pos == target
        paths << path + [:A]
        next
      end

      x, y = from_pos(pos)

      dirs = []
      dx = (tx - x) <=> 0
      dirs << to_pos(dx, 0) if dx != 0
      dy = (ty - y) <=> 0
      dirs << to_pos(0, dy) if dy != 0

      dirs.each do |dpos|
        npos = pos + dpos
        queue << [npos, path + [dpos]] if pad[:valid].include?(npos)
      end
    end
    @key_to_key_cache[cache_key] = paths
  end
  return paths
end

# Find the minimum sequence length for a given depth (number of robots).
@min_seq_cache = {}
def minimal_sequence_length(pad, code, depth)
  return code.length if depth == 0

  cache_key = [pad == KEYPAD, code, depth].hash
  minimal_length = @min_seq_cache[cache_key]
  if minimal_length.nil?
    pos = :A
    minimal_length = 0
    ndepth = depth - 1

    code.each do |key|
      lengths = key_to_key_paths(pad, pos, key).map do |path|
        minimal_sequence_length(DIRPAD, path, ndepth)
      end
      minimal_length += lengths.min
      pos = key
    end
    @min_seq_cache[cache_key] = minimal_length
  end
  return minimal_length
end

# Part 1
sum1 = @list.sum do |value, code|
  value * minimal_sequence_length(KEYPAD, code, 3)
end
puts "Complexity sum for three robots: #{sum1}"

# Part 2
sum2 = @list.sum do |value, code|
  value * minimal_sequence_length(KEYPAD, code, 26)
end
puts "Complexity sum for 26 robots: #{sum2}"
