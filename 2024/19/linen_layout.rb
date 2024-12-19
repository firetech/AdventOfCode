require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

towels_in, patterns_in = File.read(file).rstrip.split("\n\n")

@towels = towels_in.split(', ').map { |t| [t, t.length] }.sort_by(&:last)
@patterns = patterns_in.split("\n")

@cache = {}
@cache[''.hash] = 1
def ways(pattern)
  result = @cache[pattern.hash]
  if result.nil?
    result = 0
    @towels.reverse_each do |towel, len|
      if pattern[0, len] == towel
        result += ways(pattern[len..-1])
      end
    end
    @cache[pattern.hash] = result
  end
  return result
end

# Part 1
possible = @patterns.count { |pat| ways(pat) > 0 }
puts "Possible patterns: #{possible}"

# Part 2
ways = @patterns.sum { |pat| ways(pat) }
puts "Sum of ways to create each pattern: #{ways}"