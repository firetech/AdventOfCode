require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@levels = File.read(file).rstrip.split("\n").map { |l| l.split(/\s+/).map(&:to_i) }

def is_safe(report)
  diffs = report.each_cons(2).map { |a, b| a - b }
  diffs.all? { |d| d > 0 and d <= 3 } or
    diffs.all? { |d| d < 0 and d >= -3 }
end

# Part 1
safe_reports = @levels.count { |report| is_safe(report) }
puts "Safe reports: #{safe_reports}"

# Part2
safe_reports_damp = @levels.count do |report|
  safe = is_safe(report)
  if not safe
    report.each_index do |i|
      safe = is_safe(report[0...i] + report[(i+1)..-1])
      break if safe
    end
  end
  safe
end
puts "Safe reports with dampener: #{safe_reports_damp}"
