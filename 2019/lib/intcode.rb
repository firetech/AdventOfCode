class Intcode

  attr_accessor :verbose
  attr_accessor :addr

  def initialize(memory, verbose = true)
    @orig_memory = case memory
                   when String
                     memory.split(',').map(&:to_i)
                   when Array
                     memory.clone
                   end
    @verbose = verbose
    @input_buf = Queue.new
    @output_buf = Queue.new
    reset
  end

  public
  def reset
    @started = false
    @running = false
    @input_wait = false
    @memory = @orig_memory.clone
    @addr = 0
    @rel_base = 0
    @input_buf.clear
    @output_buf.clear
    true
  end

  private
  def get_addr(modes)
    mode = modes.shift
    addr = next_addr
    case mode
    when 0, nil
      # Get address from memory
      addr = self[addr]
    when 1
      # Return as is
    when 2
      # Get address from memory, add relative base
      addr = self[addr] + @rel_base
    else
      raise "Unknown param mode: #{mode}"
    end
    return addr
  end

  private
  def get_param(modes)
    return self[get_addr(modes)]
  end

  private
  def next_addr
    addr = @addr
    @addr += 1
    return addr
  end

  public
  def run
    @started = true
    @running = true
    cycles = 0
    while @running
      instruction = self[next_addr]
      opcode = instruction % 100
      parmodes = []
      instruction /= 100
      while instruction > 0
        parmodes << instruction % 10
        instruction /= 10
      end
      case opcode
      when 1, 2
        op1 = get_param(parmodes)
        op2 = get_param(parmodes)
        to = get_addr(parmodes)
        case opcode
        when 1
          self[to] = op1 + op2
        when 2
          self[to] = op1 * op2
        end
      when 3
        to = get_addr(parmodes)
        printed = false
        if @verbose
          print "Input[#{to}]: "
        end
        i = nil
        if @input_buf.empty?
          if block_given?
            @input_wait = true
            i = yield
            @input_wait = false
            if i.is_a?(Array)
              arr = i
              i = arr.shift
              arr.each { |x| @input_buf << x }
            end
          elsif @verbose
            @input_wait = true
            i = gets.to_i
            @input_wait = false
            printed = true
          end
        end
        if i.nil?
          @input_wait = true
          i = @input_buf.pop
          @input_wait = false
        end
        if @verbose and not printed
          puts i
        end
        self[to] = i
      when 4
        op = get_param(parmodes)
        if @verbose
          puts "Output: #{op}"
        end
        @output_buf << op
      when 5, 6
        op1 = get_param(parmodes)
        op2 = get_param(parmodes)
        if (opcode == 5 and op1 != 0) or
            (opcode == 6 and op1 == 0)
          @addr = op2
        end
      when 7, 8
        op1 = get_param(parmodes)
        op2 = get_param(parmodes)
        to = get_addr(parmodes)
        case opcode
        when 7
          self[to] = (op1 < op2) ? 1 : 0
        when 8
          self[to] = (op1 == op2) ? 1 : 0
        end
      when 9
        op = get_param(parmodes)
        @rel_base += op
      when 99
        @running = false
      else
        raise ArgumentError, "Unknown opcode #{opcode} at address #{@addr}"
      end
      cycles += 1
    end
    return cycles
  rescue Exception => e
    @running = false
    raise e
  end

  public
  def [](addr)
    if addr < 0
      raise "Illegal address: #{addr}"
    end
    return (@memory[addr] or 0)
  end

  public
  def []=(addr, val)
    @memory[addr] = val
  end

  public
  def memory
    @memory.clone
  end

  public
  def input(val)
    @input_buf << val
  end
  alias << input

  public
  def output
    @output_buf.pop
  end
  alias pop output

  public
  def has_output?
    (not @output_buf.empty?)
  end

  public
  def started?
    @started
  end

  public
  def running?
    @running
  end

  public
  def waiting_for_input?
    @input_wait
  end

end
