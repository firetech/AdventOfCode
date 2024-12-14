module AOCMath

  # Applied algebra... :)
  # a*x^2 + b* + c = 0
  # x = -b/(2*a) +/- sqrt(D), D = (b/2*a)^2 - c/a >= 0
  def self.quadratic_solutions(a, b, c)
    if a != 0
      d = (b / (2.0 * a))**2 - c/a.to_f
      return [] if d < 0 # I'd rather avoid complex numbers...
      neg_b_div_2a = -b / (2.0 * a)
      return [ neg_b_div_2a ] if d == 0
      d_sqrt = Math.sqrt(d)
      return [ neg_b_div_2a - d_sqrt, neg_b_div_2a + d_sqrt ]
    elsif b != 0
      # a = 0 => Linear function
      return [ -c / b.to_f ]
    elsif c != 0
      # This function is constant, but not 0...
      return []
    else
      # a = b = c = 0, any x is a valid solution
      return nil
    end
  end


  # Graciously stolen from https://rosettacode.org/wiki/Chinese_remainder_theorem#Ruby
  def self.extended_gcd(a, b)
    last_remainder, remainder = a.abs, b.abs
    x, last_x, y, last_y = 0, 1, 1, 0
    while remainder != 0
      last_remainder, (quotient, remainder) = remainder, last_remainder.divmod(remainder)
      x, last_x = last_x - quotient*x, x
      y, last_y = last_y - quotient*y, y
    end
    return last_remainder, last_x * (a < 0 ? -1 : 1)
  end
  def self.invmod(e, et)
    g, x = extended_gcd(e, et)
    if g != 1
      raise 'Multiplicative inverse modulo does not exist!'
    end
    x % et
  end
  def self.chinese_remainder(mods, remainders)
    max = mods.inject( :* )  # product of all moduli
    series = remainders.zip(mods).map{ |r,m| (r * max * invmod(max/m, m) / m) }
    series.inject( :+ ) % max
  end

end
