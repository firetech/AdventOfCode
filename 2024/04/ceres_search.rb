require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@grid = File.read(file).rstrip.split("\n")

# Part 1
xmas_count = 0
@grid.each_with_index do |line, y|
  x = -1
  until (x = line.index('X', x + 1)).nil?
    # Horizontal
    if @grid[y][x+1] == 'M' and
        @grid[y][x+2] == 'A' and
        @grid[y][x+3] == 'S'
      xmas_count += 1
    end
    # Backwards
    if x >= 3 and
        @grid[y][x-1] == 'M' and
        @grid[y][x-2] == 'A' and
        @grid[y][x-3] == 'S'
      xmas_count += 1
    end
    # Down
    if @grid[y+1] and @grid[y+1][x] == 'M' and
        @grid[y+2] and @grid[y+2][x] == 'A' and
        @grid[y+3] and @grid[y+3][x] == 'S'
      xmas_count += 1
    end
    # Up
    if y >= 3 and
        @grid[y-1][x] == 'M' and
        @grid[y-2][x] == 'A' and
        @grid[y-3][x] == 'S'
      xmas_count += 1
    end
    # Up Left
    if x >= 3 and y >= 3 and
        @grid[y-1][x-1] == 'M' and
        @grid[y-2][x-2] == 'A' and
        @grid[y-3][x-3] == 'S'
      xmas_count += 1
    end
    # Up Right
    if y >= 3 and
        @grid[y-1][x+1] == 'M' and
        @grid[y-2][x+2] == 'A' and
        @grid[y-3][x+3] == 'S'
      xmas_count += 1
    end
    # Down Left
    if x >= 3 and
        @grid[y+1] and @grid[y+1][x-1] == 'M' and
        @grid[y+2] and @grid[y+2][x-2] == 'A' and
        @grid[y+3] and @grid[y+3][x-3] == 'S'
      xmas_count += 1
    end
    # Down Right
    if @grid[y+1] and @grid[y+1][x+1] == 'M' and
        @grid[y+2] and @grid[y+2][x+2] == 'A' and
        @grid[y+3] and @grid[y+3][x+3] == 'S'
      xmas_count += 1
    end
  end
end

puts "XMAS appearances: #{xmas_count}"

# Part 2
MS = ['MS', 'SM']
mas_count = 0
@grid.each_with_index do |line, y|
  next if y < 1 or @grid[y+1].nil?
  x = -1
  until (x = line.index('A', x + 1)).nil?
    next if x < 1
    if MS.include?([@grid[y-1][x-1], @grid[y+1][x+1]].join) and
        MS.include?([@grid[y+1][x-1], @grid[y-1][x+1]].join)
      mas_count += 1
    end
  end
end

puts "X-MAS appearances: #{mas_count}"
