require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'
#file = 'example2'

OPCODES = {
  0 => ->(r, op) { # adv
    r[:A] >>= combo(r, op)
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
    r[:B] = r[:A] >> combo(r, op)
  },
  7 => ->(r, op) { # cdv
    r[:C] = r[:A] >> combo(r, op)
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
  while ip < @program.length
    type, val = OPCODES[@program[ip]][r, @program[ip+1]]
    ip += 2
    case type
    when :out
      yield val
    when :ip
      ip = val
    end
  end
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
out = []
run(@registers.clone) { |o| out << o }
puts "Program output: #{out.join(',')}"

# Part 2
# Due to how the input program works, the last output value is only affected
# by the highest three bits in A. The second-to-last output value is similarily
# selected by the next three bits (but also any higher bits), and so on.
# Therefore, we can work backwards. Begin finding any A values that give the
# correct _last_ output digit. Then, shift that value left three bits, and find
# any lower three bits in the new value(s) that give the correct second-to-last
# output digit, and continue until the whole program is found. The first value
# we find, that gives the complete program, is the lowest value.
def find_quine
  queue = [[0, 0]]
  length = @program.length
  until queue.empty?
    last_a, last_offset = queue.shift

    from = last_a << 3
    to = from | 0b111
    offset = last_offset + 1
    if offset > length
      break
    end
    next_index = length - offset
    (from..to).each do |a|
      run({
        A: a,
        B: @registers[:B],
        C: @registers[:C]
      }) do |out|
        if out == @program[next_index]
          next_index += 1
        else
          break
        end
      end
      next unless next_index == length

      if offset == length
        return a
      else
        queue << [a, offset]
      end
    end
  end
  return nil
end

a = find_quine
raise "No quine" if a.nil?
puts "Lowest quine A value: #{a}"
