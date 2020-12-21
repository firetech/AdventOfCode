file = 'input'; width = 50; height = 6
#file = 'example1'; width = 7; height = 3

grid = Array.new(height) { Array.new(width, ' ') }
File.read(file).strip.split("\n").each do |line|
  case line
  when /\Arect (\d+)x(\d+)\z/
    w, h = Regexp.last_match(1).to_i, Regexp.last_match(2).to_i
    h.times do |y|
      grid[y][0...w] = ['#'] * w
    end
  when /\Arotate row y=(\d+) by (\d+)\z/
    y, r = Regexp.last_match(1).to_i, Regexp.last_match(2).to_i
    grid[y].unshift(*grid[y].pop(r))
  when /\Arotate column x=(\d+) by (\d+)\z/
    x, r = Regexp.last_match(1).to_i, Regexp.last_match(2).to_i
    grid_t = grid.transpose
    grid_t[x].unshift(*grid_t[x].pop(r))
    grid = grid_t.transpose
  else
    raise "Malformed line: '#{line}'"
  end
end

# Part 1
puts "Lit pixels: #{grid.flatten.count('#')}"

# Part 2
puts grid.map(&:join).join("\n")
