require 'set'
require_relative '../../lib/aoc'
require_relative '../../lib/multicore'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

map_in = File.read(file).rstrip.split("\n")
MAP_HEIGHT = map_in.length

# This works for negative coordinates, BUT ONLY if they're only ever used as
# delta values.
# I.e.
#   to_pos(3, 4) + to_pos(-2, -3) == to_pos(1, 1)
# but
#   from_pos(to_pos(-2, -3)) != [-2, -3]
Y_BITS = Math.log2(MAP_HEIGHT-1).floor + 1
def to_pos(x, y)
  return (x << Y_BITS) + y
end

DIR_TO_DXDY = [
  # Turning right:
  # 0, -1 => 1, 0
  # 1, 0 => 0, 1
  # 0, 1 => -1, 0
  # -1, 0 => 0, -1
  to_pos( 0, -1),
  to_pos( 1,  0),
  to_pos( 0,  1),
  to_pos(-1,  0)
]

def to_state(pos, dir)
  return pos << 2 | dir
end
def from_state(state)
  return state >> 2, state & 0b11
end

@start = nil
@map = {}
map_in.each_with_index do |line, y|
  line.each_char.with_index do |char, x|
    pos = to_pos(x, y)
    case char
    when '#'
      @map[pos] = false
    when '^'
      @start = pos
      @map[pos] = true
    when '.'
      @map[pos] = true
    else
      raise "Unexpected map character: '#{char}'"
    end
  end
end
raise 'No guard?!' if @start.nil?

# Part 1
pos = @start
dir = 0
@normal_path = [to_state(pos, dir)]
@first_visit = { @start => 0 }
inside = true
while inside
  npos = nil
  begin
    turning = false
    dpos = DIR_TO_DXDY[dir]
    npos = pos + dpos
    case @map[npos]
    when nil
      inside = false
      break
    when true
      @first_visit[npos] ||= @normal_path.length
    when false
      turning = true
      dir = (dir + 1) % DIR_TO_DXDY.length
    end
  end while turning
  if inside
    pos = npos
    @normal_path << to_state(npos, dir)
  end
end
puts "#{@first_visit.count} visited positions"

# Part 2
# Make a lookup table for index in @normal_path. Slightly faster than copying a
# slice of @normal_path to a new visited Set for each traversal.
@normal_path_index = Hash.new(Float::INFINITY)
@normal_path.each_with_index do |state, i|
  @normal_path_index[state] = i
end
@loop_obstructions = 0
stop = nil
begin
  input, output, stop = Multicore.run do |worker_in, worker_out|
    until (indexes = worker_in[]).nil?
      loop_count = 0
      indexes.each do |i|
        block_pos, _ = from_state(@normal_path[i])
        state = @normal_path[i-1]
        pos, dir = from_state(state)
        visited = Set[state]
        is_loop = false
        inside = true
        while inside
          npos = nil
          begin
            turning = false
            dpos = DIR_TO_DXDY[dir]
            npos = pos + dpos
            at_pos = @map[npos]
            if at_pos.nil?
              inside = false
              break
            elsif not at_pos or npos == block_pos
              turning = true
              dir = (dir + 1) % DIR_TO_DXDY.length
            end
          end while turning
          if inside
            pos = npos
            state = to_state(pos, dir)
            if @normal_path_index[state] < i or not visited.add?(state)
              is_loop = true
              break
            end
          end
        end
        loop_count += 1 if is_loop
      end
      worker_out[loop_count]
    end
  end
  inputs = 0
  @first_visit.values.each_slice(20) do |list|
    input << list
    inputs += 1
  end
  inputs.times do
    @loop_obstructions += output.pop
  end
ensure
  stop[]
end
puts "#{@loop_obstructions} possible obstructions cause a loop"
