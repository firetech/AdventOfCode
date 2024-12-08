require 'set'
require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'
#file = 'example2'

@map = File.read(file).rstrip.split("\n")
@map_x_range = (0...@map.first.length)
@map_y_range = (0...@map.length)
@nodes = {}
@map.each_with_index do |line, y|
  x = -1
  until (x = line.index(/[a-zA-Z0-9]/, x + 1)).nil?
    freq = line[x]
    @nodes[freq] ||= []
    @nodes[freq] << [x, y]
  end
end

# Part 1
@antinodes1 = Set[]
@nodes.each do |freq, freq_nodes|
  freq_nodes.permutation(2) do |(x_near, y_near), (x_far, y_far)|
    antinode_x = x_near - (x_far - x_near)
    next unless @map_x_range.include?(antinode_x)
    antinode_y = y_near - (y_far - y_near)
    next unless @map_y_range.include?(antinode_y)
    @antinodes1 << [antinode_x, antinode_y]
  end
end
puts "Number of first antinodes: #{@antinodes1.count}"

# Part 2
@antinodes2 = Set.new(@nodes.values.flatten(1))
@nodes.each do |freq, freq_nodes|
  freq_nodes.permutation(2) do |(x_near, y_near), (x_far, y_far)|
    dx = x_far - x_near
    antinode_x = x_near - dx
    dy = y_far - y_near
    antinode_y = y_near - dy
    while @map_x_range.include?(antinode_x) and @map_y_range.include?(antinode_y)
      @antinodes2 << [antinode_x, antinode_y]
      antinode_x -= dx
      antinode_y -= dy
    end
  end
end
puts "Total number of antinodes: #{@antinodes2.count}"
