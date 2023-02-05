# For advanced users:
# You can put some quick verification tests here, any method
# that starts with the `test_` will be run when you save this file.

# Here is an example test and game

# To run the test: ./dragonruby mygame --eval app/tests.rb --no-tick

# require 'app/nd_array.rb'

def test_nd_array_basics(_args, assert)
  p = NDArray.new([1, 2, 3, 4], [2, 2])

  # assert.equal!(p.dtype, "float32", 'Bad')
  assert.equal!(p.shape.length, 2, "shape.length should be 2 but was #{p.shape.length}")
  assert.equal!(p.shape[0], 2, "shape[0] should be 2 but was #{p.shape[0]}")
  assert.equal!(p.shape[1], 2, "shape[1] should be 2 but was #{p.shape[1]}")
  assert.equal!(p.stride[0], 2, "stride[0] should be 2 but was #{p.stride[0]}")
  assert.equal!(p.stride[1], 1, "stride[1] should be 2 but was #{p.stride[1]}")
  assert.equal!(p[1, 1], 4, "[1][1] should be 4 but was #{p[1, 1]}")
  p[1, 1] = 5
  assert.equal!(p[1, 1], 5, "[1][1] should be 5 after assignment but was #{p[1, 1]}")
end

def test_nd_array_index(_args, assert)
  p = NDArray.new([1,2,3,4], [2,2])

  assert.equal!(p.index(0, 0), 0)
  assert.equal!(p.index(0, 1), 1)
  assert.equal!(p.index(1, 0), 2)
  assert.equal!(p.index(1, 1), 3)
end

def test_nd_array_pick(_args, assert)
  x = NDArray.new(Array.new(25, 0), [5, 5])

  x.set(0, 0, 1)
  x.set(4, 0, 5)
  x.set(0, 4, 10)

  y = x.pick(0)
  assert.equal!(y.get(0), 1)
  assert.equal!(y.get(1), 0)
  assert.equal!(y.get(2), 0)
  assert.equal!(y.get(3), 0)
  assert.equal!(y.get(4), 10)
  assert.equal!(y.shape.join(','), '5')

  y = x.pick(-1, 0)
  assert.equal!(y.get(0), 1)
  assert.equal!(y.get(1), 0)
  assert.equal!(y.get(2), 0)
  assert.equal!(y.get(3), 0)
  assert.equal!(y.get(4), 5)
  assert.equal!(y.shape.join(','), '5')

  y = x.pick(nil, 0)
  assert.equal!(y.get(0), 1)
  assert.equal!(y.get(1), 0)
  assert.equal!(y.get(2), 0)
  assert.equal!(y.get(3), 0)
  assert.equal!(y.get(4), 5)
  assert.equal!(y.shape.join(','), '5')
end

def test_nd_to_a(_args, assert)
  # 2d
  n = NDArray.new([1, 2, 3, 4], [2, 2])
  a = n.to_a
  assert.equal!(n.get(0, 0), a[0][0])
  assert.equal!(n.get(1, 0), a[1][0])
  assert.equal!(n.get(0, 1), a[0][1])
  assert.equal!(n.get(1, 1), a[1][1])

  # 3d
  n = NDArray.new(iota(24), [2, 3, 4])
  a = n.to_a
  2.times do |x|
    3.times do |y|
      4.times do |z|
        assert.equal!(n.get(x, y, z), a[x][y][z])
      end
    end
  end
  # puts "-" * 100
  # puts n.to_a
  # puts "-" * 100
end

def test_nd_array_scalars(_args, assert)
  p = NDArray.new([1,2,3,4])
  c = p.pick(0)
  assert.equal!(c.get(), 1)
  assert.equal!(c.set(10), 10)
  assert.equal!(p.get(0), 10)
  c = p.pick(3)
  assert.equal!(c.index(), 3)
  assert.equal!(c.shape, [])
  assert.equal!(c.order, [])
  assert.equal!(c.stride, [])
  assert.equal!(c.get(), 4)
  assert.equal!(c.lo(), c)
  assert.equal!(c + 1, 5)
  # Test trivial array
  assert.equal!(c.pick().dimension, -1)
end

def test_ndarray_hi(_args, assert)
  x = NDArray.new(Array.new(9, 0.0), [3, 3])
  y = x.hi(1, 2)
  assert.equal!(y.shape.join(","), "1,2")
  assert.equal!(y.stride.join(","), x.stride.join(","))
  assert.equal!(y.offset, 0)

  y.set(0, 1, 1)
  assert.equal!(x.get(0, 1), 1)

  assert.equal!(x.hi(nil, 2).shape.join(","), "3,2")
end

def test_ndarray_lo(_args, assert)
  x = NDArray.new(Array.new(9, 0.0), [3, 3])
  y = x.lo(1, 2)
  assert.equal!(y.shape.join(","), "2,1")
  assert.equal!(y.stride.join(","), x.stride.join(","))
  assert.equal!(y.offset, 3+2)

  y.set(0, 0, 1)
  assert.equal!(x.get(1, 2), 1)
end

def test_ndarray_accessors(_args, assert)
  (1..4).to_a.each do |d|
    shape = Array.new(d, 3)
    x = NDArray.new(Array.new(1000, 0.0), shape)
    x.set(1,1,1,1,1,1,1,1,1)
    assert.equal!(x.get(1,1,1,1,1,1,1), 1, "Float get/set array d=#{d}")

    array1D = NDArray.new(Array.new(1000, 0))
    x = NDArray.new(array1D, shape)
    x.set(1,1,1,1,1,1,1,1,1)
    assert.equal!(x.get(1,1,1,1,1,1,1), 1, "Int NDArray get/set generic d=#{d}")
  end
end

def test_ndarray_size(_args, assert)
  x = NDArray.new(Array.new(100, 0.0), [2, 3, 5])
  assert.equal!(x.size, 2 * 3 * 5)
  assert.equal!(x.pick(0, 0, 0).size, 1)

  (1..4).to_a.each do |d|
    x = NDArray.new(Array.new(256, 0.0), Array.new(d, 2))
    assert.equal!(x.size, 1 << d, "size d=#{d}")
  end
end

def test_ndarray_step(_args, assert)
  x = NDArray.new(iota(10))

  y = x.step(-1)
  10.times do |i|
    assert.equal!(y.get(i), (9-i))
  end

  z = y.step(-1)
  10.times do |i|
    assert.equal!(z.get(i), i)
  end

  w = x.step(2)
  assert.equal!(w.shape[0], 5)
  5.times do |i|
    assert.equal!(w.get(i), 2 * i)
  end

  a = w.step(-1)
  b = y.step(2)
  assert.equal!(a.shape, b.shape)
  5.times do |i|
    assert.equal!(a.get(i) + 1, b.get(i))
  end
end

# var ps = [[0, 1, 2], [0, 2, 1], [1, 0, 2], [1, 2, 0], [2, 0, 1], [2, 1, 0]]
# ndarray = require("./ndarray.js")
# console.log(ps.map((p) => ndarray(p, p, p).order))

ORDERS = [
  [ 0, 1, 2 ],
  [ 0, 2, 1 ],
  [ 1, 0, 2 ],
  [ 1, 2, 0 ],
  [ 2, 0, 1 ],
  [ 2, 1, 0 ]
].zip([
  [ 0, 1, 2 ],
  [ 0, 2, 1 ],
  [ 1, 0, 2 ],
  [ 2, 0, 1 ],
  [ 1, 2, 0 ],
  [ 2, 1, 0 ]
])

def test_ndarray_order(_args, assert)
  assert.equal!(INVERTS, ORDERS)

  assert.equal!(NDArray.new([0]).pick(0).order, [])

  assert.equal!(NDArray.new(Array.new(2), iota(2), [0, 1]).order, [0, 1])
  assert.equal!(NDArray.new(Array.new(2), iota(2), [1, 0]).order, [1, 0])

  ORDERS.each do |from, to|
    assert.equal!(NDArray.new(from, from, from).order, to)
  end

  f = 1
  (1..5).to_a.each do |d|
    f *= d
    f.times do |r|
      p = Permutations.unrank(d, r)
      x = NDArray.new(Array.new(d, 0), Array.new(d, 0), p.dup)
      assert.equal!(x.order, Permutations.invert(p.dup), "p #{p}, invert(p) #{Permutations.invert(p)}, stride #{x.stride}, order #{x.order} incorrect")
    end
  end
end

def test_ndarray_transpose(_args, assert)
  x = NDArray.new(Array.new(6), [2, 3])
  y = x.transpose(1, 0)
  assert.equal!(x.shape[0], y.shape[1])
  assert.equal!(x.shape[1], y.shape[0])
  assert.equal!(x.stride[0], y.stride[1])
  assert.equal!(x.stride[1], y.stride[0])

  f = 1
  shape = []
  (1..4).to_a.each do |d|
    shape.push(d)
    f *= d
    x = NDArray.new(Array.new(f), shape, shape)
    f.times do |r|
      p = Permutations.unrank(d, r)
      xt = x.transpose(*p)
      xord = xt.order
      pinv = Permutations.invert(p.dup)
      assert.equal!(xord, pinv)

      d.times do |i|
        assert.equal!(xt.shape[i], x.shape[p[i]])
        assert.equal!(xt.stride[i], x.stride[p[i]])
      end
    end
  end
end

# test("toJSON", function(t) {

#   var x = ndarray(new Float32Array(10))

#   t.same(JSON.stringify(x.shape), "[10]")

#   t.end()
# })

# test("generic", function(t) {
#   var hash = {}
#   var hashStore = {
#     get: function(i) {
#       return +hash[i]
#     },
#     set: function(i,v) {
#       return hash[i]=v
#     },
#     length: Infinity
#   }
#   var array = ndarray(hashStore, [1000,1000,1000])

#   t.equals(array.dtype, "generic")
#   t.same(array.shape.slice(), [1000,1000,1000])

#   array.set(10,10,10, 1)
#   t.equals(array.get(10,10,10), 1)
#   t.equals(array.pick(10).dtype, "generic")
#   t.equals(+array.pick(10).pick(10).pick(10), 1)

#   t.end()
# })


def test_nildarray(_args, assert)
  # TODO: test other methods compared to ndarray.js
  n = NilDArray.new([1])
  assert.equal!(n.data, [1])
  assert.equal!(n.shape, [])
  assert.equal!(n.stride, [])
  assert.equal!(n.offset, nil)
  assert.equal!(n.dimension, -1)
  assert.equal!(n.order, [])
  assert.equal!(n.get, nil)
end

$gtk.reset rand(1_000_000)
# $gtk.log_level = :off
$gtk.tests.start
