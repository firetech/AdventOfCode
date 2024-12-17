require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'
#file = 'example2'

OPCODES = {
  0 => ->(r, op) { # adv
    r[:A] /= (1 << combo(r, op))
  },
  1 => ->(r, op) { # bxl
    r[:B] ^= op
  },
  2 => ->(r, op) { # bst
    r[:B] = combo(r, op) & 0b111
  },
  3 => ->(r, op) { # jnz
    return :ip, op if r[:A] != 0
  },
  4 => ->(r, op) { # bxc
    r[:B] ^= r[:C]
  },
  5 => ->(r, op) { # out
    return :out, combo(r, op) & 0b111
  },
  6 => ->(r, op) { # bdv
    r[:B] = r[:A] / (1 << combo(r, op))
  },
  7 => ->(r, op) { # cdv
    r[:C] = r[:A] / (1 << combo(r, op))
  },
}

def combo(r, op)
  case op
  when 0..3
    return op
  when 4
    return r[:A]
  when 5
    return r[:B]
  when 6
    return r[:C]
  end
  raise "Invalid combo operand: #{op}"
end

def run(r)
  ip = 0
  out = []
  while ip < @program.length
    type, val = OPCODES[@program[ip]][r, @program[ip+1]]
    ip += 2
    case type
    when :out
      out << val
    when :ip
      ip = val
    end
  end
  return out
end

@registers = {}
@program = nil
File.read(file).rstrip.split("\n").each do |line|
  case line
  when /\ARegister ([A-C]): (\d+)\z/
    @registers[Regexp.last_match(1).to_sym] = Regexp.last_match(2).to_i
  when ''
    next
  when /\AProgram: ((?:[0-7](?:,|\z))+)/
    @program = Regexp.last_match(1).split(',').map(&:to_i)
  else
    raise "Malformed line: '#{line}'"
  end
end

# Part 1
out = run(@registers.clone)
puts "Program output: #{out.join(',')}"

# Part 2
# Due to how the input program works, the last output value is only affected
# by the highest three bits in A. The second-to-last output value is similarily
# selected by the next three bits (but also any higher bits).
# Therefore, we can work backwards. Begin finding any A values that give the
# correct _last_ output digit. Then, shift that value left three bits, and find
# any lower three bits in the new value(s) that give the correct last two output
# digits, and continue until the whole program is found. The first such value we
# find is the lowest value.
def find_quine
  queue = [[0, 0]]
  target = @program.length
  until queue.empty?
    last_a, last_length = queue.shift

    from = last_a << 3
    to = from | 0b111
    length = last_length + 1
    if length > target
      break
    end
    expect = @program.last(length)
    (from..to).each do |a|
      out = run({
        A: a,
        B: @registers[:B],
        C: @registers[:C]
      })
      if out == expect
        if length == target
          return a
        else
          queue << [a, length]
        end
      end
    end
  end
  return nil
end

a = find_quine
raise "No quine" if a.nil?
puts "Lowest quine A value: #{a}"
