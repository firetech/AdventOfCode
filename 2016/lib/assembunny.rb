class AssemBunny
  def initialize(file)
    @code = File.read(file).strip.split("\n").map do |line|
      case line
      when /\Acpy (-?\d+|[[:lower:]]) ([[:lower:]])\z/
        [ :cpy, reg_or_int(Regexp.last_match(1)), Regexp.last_match(2).to_sym ]
      when /\A(inc|dec) ([[:lower:]])\z/
        [ Regexp.last_match(1).to_sym, Regexp.last_match(2).to_sym ]
      when /\Ajnz (-?\d+|[[:lower:]]) (-?\d+|[[:lower:]])\z/
        [ :jnz, reg_or_int(Regexp.last_match(1)), reg_or_int(Regexp.last_match(2)) ]
      else
        raise "Malformed line: '#{line}'"
      end
    end
    @code.each(&:freeze)
    @code.freeze
  end

  public
  def run(init_reg = {})
    code = @code.dup
    ip = 0
    reg = Hash.new(0)
    reg.merge!(init_reg)
    while ip < code.length
      next_ip = ip + 1
      instr, arg1, arg2 = code[ip]
      case instr
      when :cpy
        if after_mul = skip_mul(arg1, arg2, code, ip, reg)
          next_ip = after_mul
        else
          set(reg, arg2, get(reg, arg1))
        end
      when :inc
        if after_add = skip_add(arg1, code, ip, reg)
          next_ip = after_add
        else
          set(reg, arg1, get(reg, arg1) + 1)
        end
      when :dec
        set(reg, arg1, get(reg, arg1) - 1)
      when :jnz
        if get(reg, arg1) != 0
          next_ip = ip + get(reg, arg2)
        end
      else
        raise "Unknown instruction: '#{instr}'"
      end
      ip = next_ip
    end
    return reg
  end

  # Skip multiplication:
  #   cpy B C
  #   inc A
  #   dec C
  #   jnz C -2
  #   dec D
  #   jnz D -5
  # is equivalent to A += B * D (and C = 0, D = 0)
  MUL_SEQUENCE = [:cpy, :inc, :dec, :jnz, :dec, :jnz].freeze
  private
  def skip_mul(cpy_arg1, cpy_arg2, code, ip, reg)
    sequence = code[ip, MUL_SEQUENCE.length]
    if sequence.map(&:first) == MUL_SEQUENCE and
        sequence[3][1] == cpy_arg2 and sequence[3][2] == -2 and sequence[5][2] == -5
      target = sequence[1][1]
      r1 = cpy_arg2
      r2 = sequence[5][1]
      if [target, r1, r2].all? { |r| r.is_a? Symbol } and sequence[2][1] == r1 and sequence[4][1] == r2
        reg[target] += get(reg, cpy_arg1) * reg[r2]
        reg[r1] = 0
        reg[r2] = 0
        return ip + MUL_SEQUENCE.length
      end
    end
    return false
  end

  # Skip addition:
  #   inc A
  #   dec C
  #   jnz C -2
  # is equivalent to A += C (and C = 0)
  ADD_SEQUENCE = [:inc, :dec, :jnz].freeze
  private
  def skip_add(target, code, ip, reg)
    sequence = code[ip, ADD_SEQUENCE.length]
    if sequence.map(&:first) == ADD_SEQUENCE and sequence[2][2] == -2
      r1 = sequence[2][1]
      if [target, r1].all? { |r| r.is_a? Symbol } and sequence[1][1] == r1
        reg[target] += reg[r1]
        reg[r1] = 0
        return ip + ADD_SEQUENCE.length
      end
    end
    return false
  end

  private
  def reg_or_int(arg)
    if arg =~ /\A[[:lower:]]\z/
      return arg.to_sym
    elsif arg.to_i.to_s == arg
      return arg.to_i
    else
      raise "Bad argument: '#{arg}'"
    end
  end

  private
  def get(reg, arg)
    case arg
    when Symbol
      return reg[arg]
    when Numeric
      return arg
    else
      raise "Unknown argument type: #{arg.class.name}"
    end
  end

  private
  def set(reg, r, value)
    if not r.is_a?(Symbol)
      return
    end
    reg[r] = value
  end
end
