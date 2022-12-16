file = ARGV[0] || 'input'
#file = 'example1'

@map = {}
File.read(file).rstrip.split("\n").each do |line|
  case line
  when /\AValve (.*) has flow rate=(\d+); tunnels? leads? to valves? ((?:.*(?:, |\z))+)/
    @map[Regexp.last_match(1)] = {
      flow:    Regexp.last_match(2).to_i,
      tunnels: Regexp.last_match(3).split(', ')
    }
  else
    raise "Malformed line: '#{line}'"
  end
end

@valve_to_valve = {}
@map.each_key do |valve|
  queue = [valve]
  dist = { valve => 0 }
  until queue.empty?
    pos = queue.shift
    this_dist = dist[pos]
    @map[pos][:tunnels].each do |new_pos|
      next if dist.has_key?(new_pos)
      dist[new_pos] = this_dist + 1
      queue << new_pos
    end
  end
  dist.delete(valve)
  dist.reject! { |valve, cost| @map[valve][:flow] == 0 }
  @valve_to_valve[valve] = dist
end

# Part 1
@cache = {}
def dfs(pos = 'AA', open = [], time = 30)
  state = [pos, open, time].hash
  val = @cache[state]
  if val.nil?
    val = 0
    @valve_to_valve[pos].each do |new_pos, cost|
      next if open.include?(new_pos) or cost > time
      new_time = time - cost - 1
      new_flow = @map[new_pos][:flow] * new_time
      new_pressure = new_flow + dfs(new_pos, (open + [new_pos]).sort, new_time)
      if new_pressure > val
        val = new_pressure
      end
    end
    @cache[state] = val
  end
  return val
end

puts "Most pressure released: #{dfs}"


# Part 2
def dfs2(pos = 'AA', open = [], time = 26)
  val = dfs('AA', open, 26)
  @valve_to_valve[pos].each do |new_pos, cost|
    next if open.include?(new_pos) or cost > time
    new_time = time - cost - 1
    new_flow = @map[new_pos][:flow] * new_time
    new_pressure = new_flow + dfs2(new_pos, (open + [new_pos]).sort, new_time)
    if new_pressure > val
      val = new_pressure
    end
  end
  return val
end

puts "Most pressure released with help: #{dfs2}"
