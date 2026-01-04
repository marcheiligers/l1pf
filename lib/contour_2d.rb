# "use strict"

# module.exports = getContours

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

def getParallelCountours(array, direction)
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

  m.times do |jj|
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
  (1...n).each do |i|
    a = false
    b = false
    x0 = 0
    j = 0
    m.times do |jj|
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
      if a
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
  m.times do |jj|
    j = jj
    b = array.get(n - 1, j) != 0
    next if b == a

    contours.push(Segment.new(j, x0, direction, n)) if a
    x0 = j if b
    a = b
  end
  j = m

  contours.push(Segment.new(j, x0, direction, n)) if a

  contours
end

def getVertices(contours)
  vertices = Array.new(contours.length * 2)
  contours.length.times do |i|
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

def compareVertex(a, b)
  d = a.x - b.x
  return d unless d == 0

  d = a.y - b.y
  return d unless d == 0

  a.orientation - b.orientation
end


def getContours(array, clockwise)
  clockwise = !!clockwise

  # First extract horizontal contours and vertices
  hcontours = getParallelCountours(array, 0)
  hvertices = getVertices(hcontours)
  hvertices.sort! { |a, b| compareVertex(a, b) }

  # Extract vertical contours and vertices
  vcontours = getParallelCountours(array.transpose(1, 0), 1)
  vvertices = getVertices(vcontours)
  vvertices.sort! { |a, b| compareVertex(a, b) }

  # Glue horizontal and vertical vertices together
  hvertices.length.times do |i|
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
  hcontours.length.times do |i|
    h = hcontours[i]
    loops.push(walk(h, clockwise)) if !h.visited
  end

  # Return
  loops
end
