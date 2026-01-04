# Tests for contour2d
# Translated from: https://github.com/mikolalysenko/contour-2d/blob/master/test/test.js

def compareVertex(a, b)
  d = a[1] - b[1]
  return d if d != 0
  a[0] - b[0]
end

def canonicalForm(loops)
  # Make copy
  loops = loops.map { |l| l.dup }

  # First put each loop in canonical form so top-left entry is at the root
  loops.length.times do |j|
    l = loops[j]
    tl = 0
    l.length.times do |i|
      if compareVertex(l[i], l[tl]) < 0
        tl = i
      end
    end
    s0 = l[tl..-1]
    s1 = l[0...tl]
    s0.concat(s1)
    loops[j] = s0
  end

  # Then sort loops
  loops.sort! { |a, b| compareVertex(a[0], b[0]) }
  loops
end

def test_contour2d_basic_square(_args, assert)
  # Test basic 2x2 square, counter-clockwise
  image = [
    [0, 0, 0, 0],
    [0, 1, 1, 0],
    [0, 1, 1, 0],
    [0, 0, 0, 0]
  ]

  grid = NDArray.new(image.flatten, [4, 4])
  result = getContours(grid, false)

  expected = [
    [[1, 1], [1, 3], [3, 3], [3, 1]]
  ]

  result_canonical = canonicalForm(result)
  expected_canonical = canonicalForm(expected)

  assert.equal!(result_canonical, expected_canonical, 'basic square counter-clockwise')
end

def test_contour2d_basic_square_cw(_args, assert)
  # Test basic 2x2 square, clockwise
  image = [
    [0, 0, 0, 0],
    [0, 1, 1, 0],
    [0, 1, 1, 0],
    [0, 0, 0, 0]
  ]

  grid = NDArray.new(image.flatten, [4, 4])
  result = getContours(grid, true)

  expected = [
    [[1, 1], [3, 1], [3, 3], [1, 3]]
  ]

  result_canonical = canonicalForm(result)
  expected_canonical = canonicalForm(expected)

  assert.equal!(result_canonical, expected_canonical, 'basic square clockwise')
end

def test_contour2d_complex_shape(_args, assert)
  # Test complex non-convex shape
  image = [
    [0, 0, 1, 1],
    [0, 0, 1, 1],
    [1, 1, 0, 0],
    [1, 1, 0, 0]
  ]

  grid = NDArray.new(image.flatten, [4, 4])
  result = getContours(grid, false)

  expected = [
    [[2, 0], [2, 2], [0, 2], [0, 4], [2, 4], [2, 2], [4, 2], [4, 0]]
  ]

  result_canonical = canonicalForm(result)
  expected_canonical = canonicalForm(expected)

  assert.equal!(result_canonical, expected_canonical, 'complex non-convex shape')
end

def test_contour2d_donut(_args, assert)
  # Test donut with hole
  image = [
    [1, 1, 1],
    [1, 0, 1],
    [1, 1, 1]
  ]

  grid = NDArray.new(image.flatten, [3, 3])
  result = getContours(grid, true)

  expected = [
    [[0, 0], [3, 0], [3, 3], [0, 3]],
    [[1, 1], [1, 2], [2, 2], [2, 1]]
  ]

  result_canonical = canonicalForm(result)
  expected_canonical = canonicalForm(expected)

  assert.equal!(result_canonical, expected_canonical, 'donut shape with hole')
end

def test_contour2d_single_cell(_args, assert)
  # Test single cell
  image = [
    [1]
  ]

  grid = NDArray.new(image.flatten, [1, 1])
  result = getContours(grid, true)

  expected = [
    [[0, 0], [1, 0], [1, 1], [0, 1]]
  ]

  result_canonical = canonicalForm(result)
  expected_canonical = canonicalForm(expected)

  assert.equal!(result_canonical, expected_canonical, 'single cell')
end
