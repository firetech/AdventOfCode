input = File.read('input').strip.split("\n").map(&:to_i)

#part 1
def fuel(weight)
  return [weight.to_i / 3 - 2, 0].max
end

puts "Total fuel: #{input.map { |weight| fuel(weight) }.inject(0) { |sum,x| sum + x }}"


#part 2
def all_fuel(weight)
  sum = 0
  begin
    weight = fuel(weight)
    sum += weight
  end while weight > 0
  return sum
end
puts "Actual total fuel: #{input.map { |weight| all_fuel(weight) }.inject(0) { |sum,x| sum + x }}"
