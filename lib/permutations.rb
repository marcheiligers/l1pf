module Permutations
  # Translated from https://github.com/scijs/invert-permutation

  def self.invert(pi, result = nil)
    result = result || Array.new(pi.length)
    l = pi.length
    i = -1
    while (i += 1) < l
      result[pi[i]] = i
    end
    result
  end

  # Translated from https://github.com/scijs/permutation-rank

  def self.rank(permutation)
    n = permutation.length
    case n
    when 0, 1 then return 0
    when 2 then permutation[1]
    end

    p = permutation.dup
    pinv = Array.new(n)
    r = 0
    invert(permutation, pinv)

    (n-1).downto(1) do |i|
      t = pinv[i]
      s = p[i]
      p[i] = p[t]
      p[t] = s
      pinv[i] = pinv[s]
      pinv[s] = t
      r = (r + s) * i
    end

    r
  end

  def self.unrank(n, r, p = nil)
    case n
    when 0 then return p ? p : []
    when 1
      if p
        p[0] = 0
        return p
      else
        return [0]
      end
    when 2
      if p
        if r != 0
          p[0] = 0
          p[1] = 1
        else
          p[0] = 1
          p[1] = 0
        end
        return p
      else
        return r != 0 ? [0, 1] : [1, 0]
      end
    end

    p = p || Array.new(n)
    nf = 1
    p[0] = 0
    1.upto(n - 1) do |i|
      p[i] = i
      nf *= i
    end

    (n - 1).downto(1) do |i|
      s = r == 0 || nf == 0 ? 0 : (r / nf) | 0 # TODO: is | 0 the right way to truncate to integer in Ruby?
      r = (r - s * nf) | 0 # TODO: is | 0 the right way to truncate to integer in Ruby?
      nf = (nf / i) | 0 # TODO: is | 0 the right way to truncate to integer in Ruby?
      t = p[i] | 0 # TODO: is | 0 the right way to truncate to integer in Ruby?
      p[i] = p[s] | 0 # TODO: is | 0 the right way to truncate to integer in Ruby?
      p[s] = t | 0 # TODO: is | 0 the right way to truncate to integer in Ruby?
    end

    p
  end
end
