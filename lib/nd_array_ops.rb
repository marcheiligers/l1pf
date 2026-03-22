# NDArray operations - Ruby translation of ndarray-ops
# Translated from: https://github.com/scijs/ndarray-ops

module NDArrayOps

  # Helper to iterate over ndarray elements
  def self.ndarray_iterate(arrays)
    # Get the first array to determine iteration count
    arr = arrays[0]
    return if arr.nil?

    size = arr.shape.reduce(1, :*)

    i = -1
    while (i += 1) < size
      yield i
    end
  end

  # Assign operations: add, sub, mul, div, mod, band, bor, bxor, lshift, rshift, rrshift
  # Each has 4 variants: op(a,b,c), opeq(a,b), ops(a,b,s), opseq(a,s)

  # Addition operations
  def self.ops_add(a, b, c)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = b.data[i] + c.data[i] }
    a
  end

  def self.ops_addeq(a, b)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] += b.data[i] }
    a
  end

  def self.ops_adds(a, b, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = b.data[i] + s }
    a
  end

  def self.ops_addseq(a, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] += s }
    a
  end

  # Subtraction operations
  def self.ops_sub(a, b, c)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = b.data[i] - c.data[i] }
    a
  end

  def self.ops_subeq(a, b)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] -= b.data[i] }
    a
  end

  def self.ops_subs(a, b, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = b.data[i] - s }
    a
  end

  def self.ops_subseq(a, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] -= s }
    a
  end

  # Multiplication operations
  def self.ops_mul(a, b, c)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = b.data[i] * c.data[i] }
    a
  end

  def self.ops_muleq(a, b)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] *= b.data[i] }
    a
  end

  def self.ops_muls(a, b, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = b.data[i] * s }
    a
  end

  def self.ops_mulseq(a, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] *= s }
    a
  end

  # Division operations
  def self.ops_div(a, b, c)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = b.data[i] / c.data[i] }
    a
  end

  def self.ops_diveq(a, b)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] /= b.data[i] }
    a
  end

  def self.ops_divs(a, b, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = b.data[i] / s }
    a
  end

  def self.ops_divseq(a, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] /= s }
    a
  end

  # Modulo operations
  def self.ops_mod(a, b, c)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = b.data[i] % c.data[i] }
    a
  end

  def self.ops_modeq(a, b)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] %= b.data[i] }
    a
  end

  def self.ops_mods(a, b, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = b.data[i] % s }
    a
  end

  def self.ops_modseq(a, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] %= s }
    a
  end

  # Bitwise AND operations
  def self.ops_band(a, b, c)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = b.data[i] & c.data[i] }
    a
  end

  def self.ops_bandeq(a, b)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] &= b.data[i] }
    a
  end

  def self.ops_bands(a, b, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = b.data[i] & s }
    a
  end

  def self.ops_bandseq(a, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] &= s }
    a
  end

  # Bitwise OR operations
  def self.ops_bor(a, b, c)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = b.data[i] | c.data[i] }
    a
  end

  def self.ops_boreq(a, b)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] |= b.data[i] }
    a
  end

  def self.ops_bors(a, b, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = b.data[i] | s }
    a
  end

  def self.ops_borseq(a, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] |= s }
    a
  end

  # Bitwise XOR operations
  def self.ops_bxor(a, b, c)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = b.data[i] ^ c.data[i] }
    a
  end

  def self.ops_bxoreq(a, b)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] ^= b.data[i] }
    a
  end

  def self.ops_bxors(a, b, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = b.data[i] ^ s }
    a
  end

  def self.ops_bxorseq(a, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] ^= s }
    a
  end

  # Left shift operations
  def self.ops_lshift(a, b, c)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = b.data[i] << c.data[i] }
    a
  end

  def self.ops_lshifteq(a, b)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] <<= b.data[i] }
    a
  end

  def self.ops_lshifts(a, b, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = b.data[i] << s }
    a
  end

  def self.ops_lshiftseq(a, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] <<= s }
    a
  end

  # Right shift operations
  def self.ops_rshift(a, b, c)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = b.data[i] >> c.data[i] }
    a
  end

  def self.ops_rshifteq(a, b)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] >>= b.data[i] }
    a
  end

  def self.ops_rshifts(a, b, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = b.data[i] >> s }
    a
  end

  def self.ops_rshiftseq(a, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] >>= s }
    a
  end

  # Unsigned right shift operations (Ruby doesn't have >>>, treat as >>)
  # TODO: verify that >> is the correct Ruby equivalent for JavaScript's >>> unsigned right shift
  def self.ops_rrshift(a, b, c)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = b.data[i] >> c.data[i] }
    a
  end

  def self.ops_rrshifteq(a, b)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] >>= b.data[i] }
    a
  end

  def self.ops_rrshifts(a, b, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = b.data[i] >> s }
    a
  end

  def self.ops_rrshiftseq(a, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] >>= s }
    a
  end

  # Unary operations: not, bnot, neg, recip

  # Logical NOT operations
  # TODO: verify that converting boolean to 1/0 is the correct approach for all use cases
  def self.ops_not(a, b)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = !b.data[i] ? 1 : 0 }
    a
  end

  def self.ops_noteq(a)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = !a.data[i] ? 1 : 0 }
    a
  end

  # Bitwise NOT operations
  def self.ops_bnot(a, b)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = ~b.data[i] }
    a
  end

  def self.ops_bnoteq(a)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = ~a.data[i] }
    a
  end

  # Negation operations
  def self.ops_neg(a, b)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = -b.data[i] }
    a
  end

  def self.ops_negeq(a)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = -a.data[i] }
    a
  end

  # Reciprocal operations
  def self.ops_recip(a, b)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = 1.0 / b.data[i] }
    a
  end

  def self.ops_recipeq(a)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = 1.0 / a.data[i] }
    a
  end

  # Binary comparison/logical operations: and, or, eq, neq, lt, gt, leq, geq

  # Logical AND operations
  def self.ops_and(a, b, c)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = (b.data[i] && c.data[i]) ? 1 : 0 }
    a
  end

  def self.ops_ands(a, b, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = (b.data[i] && s) ? 1 : 0 }
    a
  end

  def self.ops_andeq(a, b)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = (a.data[i] && b.data[i]) ? 1 : 0 }
    a
  end

  def self.ops_andseq(a, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = (a.data[i] && s) ? 1 : 0 }
    a
  end

  # Logical OR operations
  def self.ops_or(a, b, c)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = (b.data[i] || c.data[i]) ? 1 : 0 }
    a
  end

  def self.ops_ors(a, b, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = (b.data[i] || s) ? 1 : 0 }
    a
  end

  def self.ops_oreq(a, b)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = (a.data[i] || b.data[i]) ? 1 : 0 }
    a
  end

  def self.ops_orseq(a, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = (a.data[i] || s) ? 1 : 0 }
    a
  end

  # Equality operations
  def self.ops_eq(a, b, c)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = (b.data[i] == c.data[i]) ? 1 : 0 }
    a
  end

  def self.ops_eqs(a, b, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = (b.data[i] == s) ? 1 : 0 }
    a
  end

  def self.ops_eqeq(a, b)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = (a.data[i] == b.data[i]) ? 1 : 0 }
    a
  end

  def self.ops_eqseq(a, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = (a.data[i] == s) ? 1 : 0 }
    a
  end

  # Not equal operations
  def self.ops_neq(a, b, c)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = (b.data[i] != c.data[i]) ? 1 : 0 }
    a
  end

  def self.ops_neqs(a, b, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = (b.data[i] != s) ? 1 : 0 }
    a
  end

  def self.ops_neqeq(a, b)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = (a.data[i] != b.data[i]) ? 1 : 0 }
    a
  end

  def self.ops_neqseq(a, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = (a.data[i] != s) ? 1 : 0 }
    a
  end

  # Less than operations
  def self.ops_lt(a, b, c)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = (b.data[i] < c.data[i]) ? 1 : 0 }
    a
  end

  def self.ops_lts(a, b, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = (b.data[i] < s) ? 1 : 0 }
    a
  end

  def self.ops_lteq(a, b)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = (a.data[i] < b.data[i]) ? 1 : 0 }
    a
  end

  def self.ops_ltseq(a, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = (a.data[i] < s) ? 1 : 0 }
    a
  end

  # Greater than operations
  def self.ops_gt(a, b, c)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = (b.data[i] > c.data[i]) ? 1 : 0 }
    a
  end

  def self.ops_gts(a, b, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = (b.data[i] > s) ? 1 : 0 }
    a
  end

  def self.ops_gteq(a, b)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = (a.data[i] > b.data[i]) ? 1 : 0 }
    a
  end

  def self.ops_gtseq(a, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = (a.data[i] > s) ? 1 : 0 }
    a
  end

  # Less than or equal operations
  def self.ops_leq(a, b, c)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = (b.data[i] <= c.data[i]) ? 1 : 0 }
    a
  end

  def self.ops_leqs(a, b, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = (b.data[i] <= s) ? 1 : 0 }
    a
  end

  def self.ops_leqeq(a, b)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = (a.data[i] <= b.data[i]) ? 1 : 0 }
    a
  end

  def self.ops_leqseq(a, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = (a.data[i] <= s) ? 1 : 0 }
    a
  end

  # Greater than or equal operations
  def self.ops_geq(a, b, c)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = (b.data[i] >= c.data[i]) ? 1 : 0 }
    a
  end

  def self.ops_geqs(a, b, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = (b.data[i] >= s) ? 1 : 0 }
    a
  end

  def self.ops_geqeq(a, b)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = (a.data[i] >= b.data[i]) ? 1 : 0 }
    a
  end

  def self.ops_geqseq(a, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = (a.data[i] >= s) ? 1 : 0 }
    a
  end

  # Math unary operations: abs, acos, asin, atan, ceil, cos, exp, floor, log, round, sin, sqrt, tan

  # Absolute value
  def self.ops_abs(a, b)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = b.data[i].abs }
    a
  end

  def self.ops_abseq(a)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = a.data[i].abs }
    a
  end

  # Arc cosine
  def self.ops_acos(a, b)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = Math.acos(b.data[i]) }
    a
  end

  def self.ops_acoseq(a)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = Math.acos(a.data[i]) }
    a
  end

  # Arc sine
  def self.ops_asin(a, b)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = Math.asin(b.data[i]) }
    a
  end

  def self.ops_asineq(a)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = Math.asin(a.data[i]) }
    a
  end

  # Arc tangent
  def self.ops_atan(a, b)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = Math.atan(b.data[i]) }
    a
  end

  def self.ops_ataneq(a)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = Math.atan(a.data[i]) }
    a
  end

  # Ceiling
  def self.ops_ceil(a, b)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = b.data[i].ceil }
    a
  end

  def self.ops_ceileq(a)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = a.data[i].ceil }
    a
  end

  # Cosine
  def self.ops_cos(a, b)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = Math.cos(b.data[i]) }
    a
  end

  def self.ops_coseq(a)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = Math.cos(a.data[i]) }
    a
  end

  # Exponential
  def self.ops_exp(a, b)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = Math.exp(b.data[i]) }
    a
  end

  def self.ops_expeq(a)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = Math.exp(a.data[i]) }
    a
  end

  # Floor
  def self.ops_floor(a, b)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = b.data[i].floor }
    a
  end

  def self.ops_flooreq(a)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = a.data[i].floor }
    a
  end

  # Natural logarithm
  def self.ops_log(a, b)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = Math.log(b.data[i]) }
    a
  end

  def self.ops_logeq(a)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = Math.log(a.data[i]) }
    a
  end

  # Round
  def self.ops_round(a, b)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = b.data[i].round }
    a
  end

  def self.ops_roundeq(a)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = a.data[i].round }
    a
  end

  # Sine
  def self.ops_sin(a, b)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = Math.sin(b.data[i]) }
    a
  end

  def self.ops_sineq(a)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = Math.sin(a.data[i]) }
    a
  end

  # Square root
  def self.ops_sqrt(a, b)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = Math.sqrt(b.data[i]) }
    a
  end

  def self.ops_sqrteq(a)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = Math.sqrt(a.data[i]) }
    a
  end

  # Tangent
  def self.ops_tan(a, b)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = Math.tan(b.data[i]) }
    a
  end

  def self.ops_taneq(a)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = Math.tan(a.data[i]) }
    a
  end

  # Math commutative binary operations: max, min, atan2, pow

  # Maximum
  def self.ops_max(a, b, c)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = [b.data[i], c.data[i]].max }
    a
  end

  def self.ops_maxs(a, b, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = [b.data[i], s].max }
    a
  end

  def self.ops_maxeq(a, b)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = [a.data[i], b.data[i]].max }
    a
  end

  def self.ops_maxseq(a, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = [a.data[i], s].max }
    a
  end

  # Minimum
  def self.ops_min(a, b, c)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = [b.data[i], c.data[i]].min }
    a
  end

  def self.ops_mins(a, b, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = [b.data[i], s].min }
    a
  end

  def self.ops_mineq(a, b)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = [a.data[i], b.data[i]].min }
    a
  end

  def self.ops_minseq(a, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = [a.data[i], s].min }
    a
  end

  # Arc tangent 2
  def self.ops_atan2(a, b, c)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = Math.atan2(b.data[i], c.data[i]) }
    a
  end

  def self.ops_atan2s(a, b, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = Math.atan2(b.data[i], s) }
    a
  end

  def self.ops_atan2eq(a, b)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = Math.atan2(a.data[i], b.data[i]) }
    a
  end

  def self.ops_atan2seq(a, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = Math.atan2(a.data[i], s) }
    a
  end

  # Power
  def self.ops_pow(a, b, c)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = b.data[i] ** c.data[i] }
    a
  end

  def self.ops_pows(a, b, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = b.data[i] ** s }
    a
  end

  def self.ops_poweq(a, b)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = a.data[i] ** b.data[i] }
    a
  end

  def self.ops_powseq(a, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = a.data[i] ** s }
    a
  end

  # Math non-commutative operations (reversed arguments): atan2, pow

  # Arc tangent 2 reversed (atan2(c, b))
  def self.ops_atan2op(a, b, c)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = Math.atan2(c.data[i], b.data[i]) }
    a
  end

  def self.ops_atan2ops(a, b, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = Math.atan2(s, b.data[i]) }
    a
  end

  def self.ops_atan2opeq(a, b)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = Math.atan2(b.data[i], a.data[i]) }
    a
  end

  def self.ops_atan2opseq(a, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = Math.atan2(s, a.data[i]) }
    a
  end

  # Power reversed (c ** b)
  def self.ops_powop(a, b, c)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = c.data[i] ** b.data[i] }
    a
  end

  def self.ops_powops(a, b, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = s ** b.data[i] }
    a
  end

  def self.ops_powopeq(a, b)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = b.data[i] ** a.data[i] }
    a
  end

  def self.ops_powopseq(a, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = s ** a.data[i] }
    a
  end

  # Reduction operations

  # Any - returns true if any element is truthy
  def self.ops_any(array)
    size = array.shape.reduce(1, :*)
    i = -1
    while (i += 1) < size
      return true if array.data[i]
    end
    false
  end

  # All - returns true if all elements are truthy
  def self.ops_all(array)
    size = array.shape.reduce(1, :*)
    i = -1
    while (i += 1) < size
      return false unless array.data[i]
    end
    true
  end

  # Sum - returns sum of all elements
  def self.ops_sum(array)
    s = 0
    size = array.shape.reduce(1, :*)
    i = -1
    while (i += 1) < size
      s += array.data[i]
    end
    s
  end

  # Product - returns product of all elements
  def self.ops_prod(array)
    s = 1
    size = array.shape.reduce(1, :*)
    i = -1
    while (i += 1) < size
      s *= array.data[i]
    end
    s
  end

  # Norm2 squared - sum of squares
  def self.ops_norm2squared(array)
    s = 0
    size = array.shape.reduce(1, :*)
    i = -1
    while (i += 1) < size
      a = array.data[i]
      s += a * a
    end
    s
  end

  # Norm2 - Euclidean norm (L2 norm)
  def self.ops_norm2(array)
    Math.sqrt(NDArrayOps.ops_norm2squared(array))
  end

  # Norminf - maximum absolute value (L-infinity norm)
  def self.ops_norminf(array)
    s = 0
    size = array.shape.reduce(1, :*)
    i = -1
    while (i += 1) < size
      a = array.data[i]
      if -a > s
        s = -a
      elsif a > s
        s = a
      end
    end
    s
  end

  # Norm1 - sum of absolute values (L1 norm)
  def self.ops_norm1(array)
    s = 0
    size = array.shape.reduce(1, :*)
    i = -1
    while (i += 1) < size
      a = array.data[i]
      s += (a < 0 ? -a : a)
    end
    s
  end

  # Sup - supremum (maximum value)
  def self.ops_sup(array)
    h = -Float::INFINITY
    size = array.shape.reduce(1, :*)
    i = -1
    while (i += 1) < size
      h = array.data[i] if array.data[i] > h
    end
    h
  end

  # Inf - infimum (minimum value)
  def self.ops_inf(array)
    h = Float::INFINITY
    size = array.shape.reduce(1, :*)
    i = -1
    while (i += 1) < size
      h = array.data[i] if array.data[i] < h
    end
    h
  end

  # Argmin - returns index of minimum element
  def self.ops_argmin(array)
    v = Float::INFINITY
    index = array.shape.dup

    # Need to iterate with multi-dimensional indices
    # For simplicity, find linear index then convert
    size = array.shape.reduce(1, :*)
    min_idx = 0

    i = -1
    while (i += 1) < size
      if array.data[i] < v
        v = array.data[i]
        min_idx = i
      end
    end

    # Convert linear index to multi-dimensional index
    idx = []
    remaining = min_idx
    d = array.shape.length
    while (d -= 1) >= 0
      stride = array.shape[(d+1)..-1]&.reduce(1, :*) || 1
      idx_d = remaining / stride
      idx.unshift(idx_d)
      remaining = remaining % stride
    end

    idx
  end

  # Argmax - returns index of maximum element
  def self.ops_argmax(array)
    v = -Float::INFINITY
    index = array.shape.dup

    # Need to iterate with multi-dimensional indices
    # For simplicity, find linear index then convert
    size = array.shape.reduce(1, :*)
    max_idx = 0

    i = -1
    while (i += 1) < size
      if array.data[i] > v
        v = array.data[i]
        max_idx = i
      end
    end

    # Convert linear index to multi-dimensional index
    idx = []
    remaining = max_idx
    d = array.shape.length
    while (d -= 1) >= 0
      stride = array.shape[(d+1)..-1]&.reduce(1, :*) || 1
      idx_d = remaining / stride
      idx.unshift(idx_d)
      remaining = remaining % stride
    end

    idx
  end

  # Random - fills array with random values
  def self.ops_random(a)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = rand }
    a
  end

  # Assign - copy array b to array a
  def self.ops_assign(a, b)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = b.data[i] }
    a
  end

  # Assigns - fill array a with scalar s
  def self.ops_assigns(a, s)
    NDArrayOps.ndarray_iterate([a]) { |i| a.data[i] = s }
    a
  end

  # Equals - returns true if arrays are equal
  def self.ops_equals(a, b)
    size = a.shape.reduce(1, :*)
    size.times do |i| # TODO: convert to while loop for performance: i = -1; while (i += 1) < size
      return false if a.data[i] != b.data[i]
    end
    true
  end
end
