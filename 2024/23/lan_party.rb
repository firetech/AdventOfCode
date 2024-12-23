require 'set'
require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@connections = {}
File.read(file).rstrip.split("\n").each do |line|
  case line
  when /\A([a-z]{2})-([a-z]{2})\z/
    a = Regexp.last_match(1)
    b = Regexp.last_match(2)
    (@connections[a] ||= Set[]) << b
    (@connections[b] ||= Set[]) << a
  else
    raise "Malformed line: '#{line}'"
  end
end

# Part 1
threes_with_t = Set[]
@connections.each do |node1, list|
  next unless node1.start_with?('t')
  list.each do |node2|
    (list & @connections[node2]).each do |node3|
      threes_with_t << [node1, node2, node3].sort.hash
    end
  end
end
puts "Groups of three possibly containing chief: #{threes_with_t.length}"

# Part 2
# Use the Bron-Kerborsch algorithm (with pivoting) to find the largest "clique"
# of computers (all connected to eachother).
# (Adapted from 2018/23.)
def bron_kerbosch(possible, result = Set[], exclude = Set[])
  possible = Set.new(possible) unless possible.is_a?(Set)
  if possible.empty? and exclude.empty?
    return result
  else
    pivot = (possible + exclude).max_by { |node| @connections[node].size }
    pivot_neighbours = @connections[pivot]
    results = (possible - pivot_neighbours).map do |node|
      node_result = bron_kerbosch(
        possible & @connections[node],
        result + [node],
        exclude & @connections[node]
      )
      possible.delete(node)
      exclude << node
      node_result
    end
    if results.empty?
      return Set[]
    else
      return results.max_by(&:size)
    end
  end
end
puts "LAN party password: #{bron_kerbosch(@connections.keys).sort.join(',')}"
