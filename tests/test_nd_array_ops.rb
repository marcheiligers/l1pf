# Tests for NDArray operations
# Translated from: https://github.com/scijs/ndarray-ops/blob/master/test/test.js

def test_ndarray_ops(_args, assert)
  # Create test arrays
  x = NDArray.new(Array.new(10, 0.0), [10])
  y = NDArray.new(Array.new(10, 0.0), [10])

  # Test equals
  assert.true!(ops_equals(x, y), 'arrays should be equal initially')
  y.set(2, 1)
  assert.false!(ops_equals(x, y), 'arrays should not be equal after modifying y')

  # Test assigns
  ops_assigns(y, 5)
  10.times do |i|
    assert.equal!(y.get(i), 5, "y[#{i}] should be 5")
  end

  # Test add
  ops_add(x, y, y)
  10.times do |i|
    assert.equal!(x.get(i), 10, "x[#{i}] should be 10")
  end

  # Test addeq
  ops_addeq(x, y)
  10.times do |i|
    assert.equal!(x.get(i), 15, "x[#{i}] should be 15")
  end

  # Test adds
  ops_adds(x, y, 1)
  10.times do |i|
    assert.equal!(x.get(i), 6, "x[#{i}] should be 6")
  end

  # Test addseq
  ops_addseq(x, 2)
  10.times do |i|
    assert.equal!(x.get(i), 8, "x[#{i}] should be 8")
  end

  # Test recip
  ops_recip(x, y)
  10.times do |i|
    assert.equal!(x.get(i), 0.2, "x[#{i}] should be 0.2")
  end

  # Test negeq
  ops_negeq(x)
  10.times do |i|
    assert.equal!(x.get(i), -0.2, "x[#{i}] should be -0.2")
  end

  # Test lt
  z = NDArray.new(Array.new(10, 0), [10])
  ops_lt(z, x, y)
  10.times do |i|
    assert.true!(z.get(i) != 0, "z[#{i}] should be truthy")
  end

  # Test sqrteq
  ops_assigns(x, 4.0)
  ops_sqrteq(x)
  10.times do |i|
    assert.equal!(x.get(i), 2, "x[#{i}] should be 2")
  end

  # Test powops
  ops_powops(x, y, 2)
  10.times do |i|
    assert.equal!(x.get(i), 32, "x[#{i}] should be 32")
  end

  # Test any
  assert.true!(ops_any(z), 'any should return true')

  # Test all
  assert.true!(ops_all(z), 'all should return true')

  # Test sum
  assert.equal!(ops_sum(y), 50, 'sum should be 50')

  # Test prod
  assert.equal!(ops_prod(y), 5**10, 'prod should be 5^10')

  # Test norm2squared
  assert.equal!(ops_norm2squared(y), 250, 'norm2squared should be 250')

  # Test norm2
  assert.equal!(ops_norm2(y), Math.sqrt(250), 'norm2 should be sqrt(250)')

  # Test norminf
  assert.equal!(ops_norminf(y), 5, 'norminf should be 5')

  # Test norm1
  assert.equal!(ops_norm1(y), 50, 'norm1 should be 50')

  # Test sup
  assert.equal!(ops_sup(y), 5, 'sup should be 5')

  # Test inf
  assert.equal!(ops_inf(y), 5, 'inf should be 5')

  # Test argmax
  y.set(0, 10)
  y.set(1, -10)
  assert.equal!(ops_argmax(y), [0], 'argmax should be [0]')

  # Test argmin
  assert.equal!(ops_argmin(y), [1], 'argmin should be [1]')
end
