require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'
#file = 'example2'

inputs, outputs = File.read(file).rstrip.split("\n\n")

@network = {}
inputs.split("\n").each do |line|
  case line
  when /\A([a-z0-9]+): (0|1)\z/
    val = (Regexp.last_match(2) == '1')
    @network[Regexp.last_match(1)] = -> { val }
  else
    raise "Malformed line: '#{line}'"
  end
end

outputs.split("\n").each do |line|
  case line
  when /\A([a-z0-9]+) AND ([a-z0-9]+) -> ([a-z0-9]+)\z/
    a = Regexp.last_match(1)
    b = Regexp.last_match(2)
    @network[Regexp.last_match(3)] = -> { @network[a][] and @network[b][] }
  when /\A([a-z0-9]+) OR ([a-z0-9]+) -> ([a-z0-9]+)\z/
    a = Regexp.last_match(1)
    b = Regexp.last_match(2)
    @network[Regexp.last_match(3)] = -> { @network[a][] or @network[b][] }
  when /\A([a-z0-9]+) XOR ([a-z0-9]+) -> ([a-z0-9]+)\z/
    a = Regexp.last_match(1)
    b = Regexp.last_match(2)
    @network[Regexp.last_match(3)] = -> { @network[a][] ^ @network[b][] }
  else
    raise "Malformed line: '#{line}'"
  end
end

z_keys = @network.keys.filter { |k| k.start_with?('z') }.sort

num = 0
z_keys.reverse_each do |z|
  num <<= 1
  if @network[z][]
    num |= 1
  end
end
puts num
