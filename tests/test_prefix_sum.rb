# Tests for prefix_sum function
# Translated from: https://github.com/scijs/ndarray-prefix-sum/blob/master/test/test.js

def test_prefix_sum_1d(_args, assert)
  x = NDArray.new([1,2,3,4,5])

  NDArrayOps.prefix_sum(x)
  assert.equal!(x.get(0), 1)
  assert.equal!(x.get(1), 3)
  assert.equal!(x.get(2), 6)
  assert.equal!(x.get(3), 10)
  assert.equal!(x.get(4), 15)
end

def test_prefix_sum_1d_reversed(_args, assert)
  x = NDArray.new([1,2,3,4,5]).step(-1)
  NDArrayOps.prefix_sum(x)
  assert.equal!(x.get(0), 5)
  assert.equal!(x.get(1), 9)
  assert.equal!(x.get(2), 12)
  assert.equal!(x.get(3), 14)
  assert.equal!(x.get(4), 15)
end

def test_prefix_sum_2d(_args, assert)
  x = NDArray.new([
    0, 1, 2, 3,
    4, 5, 6, 7,
    8, 9, 10, 11,
    12, 13, 14, 15
  ], [4,4])
  NDArrayOps.prefix_sum(x)
  assert.equal!(x.get(0,0), 0)
  assert.equal!(x.get(0,1), 1)
  assert.equal!(x.get(0,2), 3)
  assert.equal!(x.get(0,3), 6)
  assert.equal!(x.get(1,0), 4)
  assert.equal!(x.get(1,1), 10)
  assert.equal!(x.get(1,2), 18)
  assert.equal!(x.get(1,3), 28)

  NDArrayOps.prefix_sum(x.transpose(1,0))
end
