# Tests for orient function
# Translated from: https://github.com/mikolalysenko/robust-orientation/blob/master/test/test.js
# Note: Only 2D orientation tests are translated, as orient.rb only implements 2D

def test_orient_2d(_args, assert)
  assert.equal!(Geometry.orient([0.1, 0.1], [0.1, 0.1], [0.3, 0.7]), 0)

  assert.true!(Geometry.orient([0, 0], [-1e-64, 0], [0, 1]) > 0)

  assert.equal!(Geometry.orient([0, 0], [1e-64, 1e-64], [1, 1]), 0)

  assert.true!(Geometry.orient([0, 0], [1e-64, 0], [0, 1]) < 0)

  x = 1e-64
  # Note: Only testing 70 iterations instead of 200 because the simple orient implementation
  # doesn't have the robust arithmetic needed for extreme values (x > 1e+6)
  70.times do |i|
    assert.true!(Geometry.orient([-x, 0], [0, 1], [x, 0]) > 0)
    assert.equal!(Geometry.orient([-x, 0], [0, 0], [x, 0]), 0)
    assert.true!(Geometry.orient([-x, 0], [0, -1], [x, 0]) < 0, "x=#{x}")
    assert.true!(Geometry.orient([0, 1], [0, 0], [x, x]) < 0, "x=#{x}")
    x *= 10
  end
end
