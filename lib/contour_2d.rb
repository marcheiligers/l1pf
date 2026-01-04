# "use strict"

# module.exports = getContours

# TODO: namespace pollution - all functions below should be wrapped in a Contour2D module

# TODO: namespace pollution - class should be nested in a module (e.g., Contour2D::Segment)
class Segment
  attr_accessor :start, :end, :direction, :height, :visited, :next, :prev

  def initialize(start_val, end_val, direction, height)
    @start = start_val
    @end = end_val
    @direction = direction
    @height = height
    @visited = false
    @next = nil
    @prev = nil
  end
end

# TODO: namespace pollution - Struct definition should be namespaced or nested in a module
ContourVertex = Struct.new(:x, :y, :segment, :orientation)

# TODO: namespace pollution - make this private/internal to the module
def getParallelCountours(array, direction) # TODO: rename to get_parallel_contours (snake_case convention; also fix typo: Countours -> Contours)
  n = array.shape[0]
  m = array.shape[1]
  contours = []

  # Scan top row
  a = false
  b = false
  c = false
  d = false
  x0 = 0
  j = 0

  m.times do |jj| # TODO: convert to while loop for performance: jj = -1; while (jj += 1) < m
    j = jj
    b = array.get(0, j) != 0
    next if b == a

    contours.push(Segment.new(x0, j, direction, 0)) if a
    x0 = j if b
    a = b
  end
  j = m

  contours.push(Segment.new(x0, j, direction, 0)) if a

  # Scan center
  (1...n).each do |i| # TODO: convert to while loop for performance: i = 0; while (i += 1) < n
    a = false
    b = false
    x0 = 0
    j = 0
    m.times do |jj| # TODO: convert to while loop for performance: jj = -1; while (jj += 1) < m
      j = jj
      c = array.get(i-1, j) != 0
      d = array.get(i, j) != 0
      next if c == a && d == b

      if a != b
        if a
          contours.push(Segment.new(j, x0, direction, i))
        else
          contours.push(Segment.new(x0, j, direction, i))
        end
      end

      x0 = j if c != d
      a = c
      b = d
    end
    j = m  # After loop, j should equal m (like JavaScript for loop)

    if a != b
      if a # TODO: is this assuming that 0 is false? ... probably ... compare to the JS
        contours.push(Segment.new(j, x0, direction, i))
      else
        contours.push(Segment.new(x0, j, direction, i))
      end
    end
  end

  # Scan bottom row
  a = false
  x0 = 0
  j = 0
  m.times do |jj| # TODO: convert to while loop for performance: jj = -1; while (jj += 1) < m
    j = jj
    b = array.get(n - 1, j) != 0
    next if b == a

    contours.push(Segment.new(j, x0, direction, n)) if a # TODO: is this assuming that 0 is false? ... probably ... compare to the JS
    x0 = j if b
    a = b
  end
  j = m

  contours.push(Segment.new(j, x0, direction, n)) if a # TODO: is this assuming that 0 is false? ... probably ... compare to the JS

  contours
end

# TODO: namespace pollution - make this private/internal to the module
def getVertices(contours) # TODO: rename to get_vertices (snake_case convention)
  vertices = Array.new(contours.length * 2)
  contours.length.times do |i| # TODO: convert to while loop for performance: l = contours.length; i = -1; while (i += 1) < l
    h = contours[i]
    if h.direction == 0
      vertices[2 * i] = ContourVertex.new(h.start, h.height, h, 0)
      vertices[2 * i + 1] = ContourVertex.new(h.end, h.height, h, 1)
    else
      vertices[2 * i] = ContourVertex.new(h.height, h.start, h, 0)
      vertices[2 * i + 1] = ContourVertex.new(h.height, h.end, h, 1)
    end
  end

  vertices
end

# TODO: namespace pollution - make this private/internal to the module
def walk(v, clockwise)
  result = []

  while !v.visited
    v.visited = true

    if v.direction != 0
      result.push([v.height, v.end])
    else
      result.push([v.start, v.height])
    end

    if clockwise
      v = v.next
    else
      v = v.prev
    end
  end

  result
end

# TODO: namespace pollution - make this private/internal to the module
def compareVertex(a, b) # TODO: rename to compare_vertex (snake_case convention)
  d = a.x - b.x
  return d unless d == 0

  d = a.y - b.y
  return d unless d == 0

  a.orientation - b.orientation
end

# TODO: namespace pollution - this is the main export, should be in a module (e.g., Contour2D.get_contours)
def getContours(array, clockwise) # TODO: rename to get_contours (snake_case convention)
  clockwise = !!clockwise # TODO: is !! the idiomatic Ruby way to convert to boolean?

  # First extract horizontal contours and vertices
  hcontours = getParallelCountours(array, 0)
  hvertices = getVertices(hcontours)
  hvertices.sort! { |a, b| compareVertex(a, b) }

  # Extract vertical contours and vertices
  vcontours = getParallelCountours(array.transpose(1, 0), 1)
  vvertices = getVertices(vcontours)
  vvertices.sort! { |a, b| compareVertex(a, b) }

  # Glue horizontal and vertical vertices together
  hvertices.length.times do |i| # TODO: convert to while loop for performance: l = hvertices.length; i = -1; while (i += 1) < l
    h = hvertices[i]
    v = vvertices[i]
    if h.orientation != 0
      h.segment.next = v.segment
      v.segment.prev = h.segment
    else
      h.segment.prev = v.segment
      v.segment.next = h.segment
    end
  end

  # Unwrap loops
  loops = []
  hcontours.length.times do |i| # TODO: convert to while loop for performance: l = hcontours.length; i = -1; while (i += 1) < l
    h = hcontours[i]
    loops.push(walk(h, clockwise)) if !h.visited
  end

  # Return
  loops
end
