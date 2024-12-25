require 'set'
require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

towels_in, patterns_in = File.read(file).rstrip.split("\n\n")

@towels = {}
towels_in.split(', ').each do |towel|
  (@towels[towel.length] ||= Set[]) << towel
end
@patterns = patterns_in.split("\n")

@cache = {}
def ways(pattern)
  result = @cache[pattern.hash]
  if result.nil?
    result = 0

    plen = pattern.length
    @towels.each do |tlen, list|
      if plen > tlen
        match = pattern[0, tlen]
        remainder = pattern[tlen, plen-tlen]
        result += ways(remainder) if list.include?(match)
      elsif plen == tlen
        result += 1 if list.include?(pattern)
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
