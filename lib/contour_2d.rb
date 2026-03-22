# "use strict"

# module.exports = getContours

module Contour2D
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

ContourVertex = Struct.new(:x, :y, :segment, :orientation)

def self.get_parallel_contours(array, direction)
  n = array.shape[0]
  m = array.shape[1]
  data = array.data
  s0 = array.stride[0]
  s1 = array.stride[1]
  off = array.offset
  contours = []

  # Scan top row
  a = false
  b = false
  c = false
  d = false
  x0 = 0
  j = 0

  jj = -1
  while (jj += 1) < m
    j = jj
    b = data[off + s1 * j] != 0
    next if b == a

    contours.push(Segment.new(x0, j, direction, 0)) if a
    x0 = j if b
    a = b
  end
  j = m

  contours.push(Segment.new(x0, j, direction, 0)) if a

  # Scan center
  i = 0
  while (i += 1) < n
    a = false
    b = false
    x0 = 0
    j = 0
    base_prev = off + s0 * (i - 1)
    base_curr = off + s0 * i
    jj = -1
    while (jj += 1) < m
      j = jj
      js1 = s1 * j
      c = data[base_prev + js1] != 0
      d = data[base_curr + js1] != 0
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
  base_last = off + s0 * (n - 1)
  jj = -1
  while (jj += 1) < m
    j = jj
    b = data[base_last + s1 * j] != 0
    next if b == a

    contours.push(Segment.new(j, x0, direction, n)) if a
    x0 = j if b
    a = b
  end
  j = m

  contours.push(Segment.new(j, x0, direction, n)) if a

  contours
end

def self.get_vertices(contours)
  vertices = Array.new(contours.length * 2)
  l = contours.length
  i = -1
  while (i += 1) < l
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

def self.walk(v, clockwise)
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

def self.compare_vertex(a, b)
  d = a.x - b.x
  return d unless d == 0

  d = a.y - b.y
  return d unless d == 0

  a.orientation - b.orientation
end

def self.get_contours(array, clockwise)
  clockwise = !!clockwise # TODO: is !! the idiomatic Ruby way to convert to boolean?

  # First extract horizontal contours and vertices
  hcontours = Contour2D.get_parallel_contours(array, 0)
  hvertices = Contour2D.get_vertices(hcontours)
  hvertices.sort! { |a, b| ((d = a.x - b.x) != 0 ? d : ((d = a.y - b.y) != 0 ? d : a.orientation - b.orientation)) }

  # Extract vertical contours and vertices
  vcontours = Contour2D.get_parallel_contours(array.transpose(1, 0), 1)
  vvertices = Contour2D.get_vertices(vcontours)
  vvertices.sort! { |a, b| ((d = a.x - b.x) != 0 ? d : ((d = a.y - b.y) != 0 ? d : a.orientation - b.orientation)) }

  # Glue horizontal and vertical vertices together
  l = hvertices.length
  i = -1
  while (i += 1) < l
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
  l = hcontours.length
  i = -1
  while (i += 1) < l
    h = hcontours[i]
    loops.push(Contour2D.walk(h, clockwise)) if !h.visited
  end

  # Return
  loops
end
end
