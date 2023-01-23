# 'use strict'

# module.exports = Graph

# var vtx = require('./vertex')
# var NIL = vtx.NIL
# var NUM_LANDMARKS = vtx.NUM_LANDMARKS
# var LANDMARK_DIST = vtx.LANDMARK_DIST

def heuristic(tdist, tx, ty, node)
  nx = node.x.to_i
  ny = node.y.to_i
  pi = Math.abs(nx-tx) + Math.abs(ny-ty)
  ndist = node.landmark
  NUM_LANDMARKS.times do |i|
    pi = Math.max(pi, tdist[i]-ndist[i])
  end
  1.0000009536743164 * pi
end

class Graph
  def initialize
    @target   = createVertex(0,0)
    @verts    = []
    @freeList = @target
    @toVisit  = NIL
    @lastS    = nil
    @lastT    = nil
    @srcX     = 0
    @srcY     = 0
    @dstX     = 0
    @dstY     = 0
    @landmarks = []
    @landmarkDist = Array.new(NUM_LANDMARKS, INFINITY) # copied from Vertex
  end

  def vertex(x, y)
    v = createVertex(x, y)
    @verts.push(v)
    v
  end

  def link(u, v)
    link(u, v) # TODO: from vertex.rb
  end

  def setSourceAndTarget(sx, sy, tx, ty)
    @srcX = sx || 0
    @srcY = sy || 0
    @dstX = tx || 0
    @dstY = ty || 0
  end

  # Mark vertex connected to source
  def addS(v)
    if (v.state & 2) == 0
      v.heuristic   = heuristic(@landmarkDist, @dstX, @dstY, v)
      v.weight      = Math.abs(@srcX - v.x) + Math.abs(@srcY - v.y) + v.heuristic
      v.state       |= 2
      v.pred        = nil
      @toVisit  = push(@toVisit, v) # TODO: from Vertex
      @freeList = insert(@freeList, v) # TODO: from Vertex
      @lastS    = v
    end
  end

  # Mark vertex connected to target
  def addT(v)
    if (v.state & 1) == 0
      v.state       ||= 1
      @freeList = insert(@freeList, v) # TODO: from Vertex
      @lastT    = v

      # Update heuristic
      d = Math.abs(v.x-this.dstX) + Math.abs(v.y-this.dstY)
      vdist = v.landmark
      tdist = @landmarkDist
      NUM_LANDMARKS.times do |i|
        tdist[i] = Math.min(tdist[i], vdist[i]+d)
      end
    end
  end

  # Retrieves the path from dst->src
  def getPath(out)
    prevX = @dstX
    prevY = @dstY
    out.push(prevX, prevY)
    head = @target.pred

    while(head)
      out.push(head.x, prevY) if prevX != head.x && prevY != head.y
      out.push(head.x, head.y) if prevX != head.x || prevY != head.y

      prevX = head.x
      prevY = head.y
      head = head.pred
    end

    out.push(@srcX, prevY) if prevX != @srcX && prevY != @srcY
    out.push(@srcX, @srcY) if prevX != @srcX || prevY != @srcY
    out
  end

  def findComponents
    verts = @verts
    n = verts.length
    n.times do |i|
      verts[i].component = -1
    end

    components = []
    n.times do |i|
      root = verts[i]
      next if root.component >= 0

      label = components.length
      root.component = label
      toVisit = [root]
      ptr = 0

      while ptr < toVisit.length
        v = toVisit[ptr += 1]
        adj = v.edges
        adj.length.times do |j|
          u = adj[j]
          next if u.component >= 0
          u.component = label
          toVisit.push(u)
        end
      end

      components.push(toVisit)
    end

    components
  end

  # Find all landmarks
  def compareVert(a, b)
    d = a.x - b.x
    return d unless d == 0

    return a.y - b.y
  end

  # For each connected component compute a set of landmarks
  def findLandmarks(component)
    component.sort(compareVert) # TODO: Compare function
    v = component[component.length >> 1]

    NUM_LANDMARKS.times do |k|
      v.weight = 0.0
      @landmarks.push(v)

      toVisit = v
      while toVisit != NIL
        v = toVisit
        v.state = 2
        toVisit = pop(toVisit) # TODO: from Vertex
        w = v.weight
        adj = v.edges

        adj.length.times do |i|
          u = adj[i]
          next if u.state == 2

          d = w + Math.abs(v.x-u.x) + Math.abs(v.y-u.y)
          if u.state == 0
            u.state = 1
            u.weight = d
            toVisit = push(toVisit, u) # TODO: from Vertex
          elsif d < u.weight
            u.weight = d
            toVisit = decreaseKey(toVisit, u) # TODO: from Vertex
          end
        end
      end

      farthestD = 0
      component.length.times do |i|
        u = component[i]
        u.state = 0
        u.landmark[k] = u.weight
        s = Float::INFINITY
        k.times do |j|
          s = Math.min(s, u.landmark[j])
        end
        if s > farthestD
          v = u
          farthestD = s
        end
      end
    end
  end

  def init
    components = findComponents
    components.length.times do |i|
      findLandmarks(components[i])
    end
  end

  # Runs a* on the graph
  def search
    target   = @target
    freeList = @freeList
    tdist    = @landmarkDist

    # Initialize target properties
    dist = Float::INFINITY

    # Test for case where S and T are disconnected
    if @lastS &&@lastT && @lastS.component == @lastT.component
      sx = @srcX.to_i
      sy = @srcY.to_i
      tx = @dstX.to_i
      ty = @dstY.to_i

      toVisit = @toVisit
      while toVisit != NIL
        node = toVisit
        nx   = node.x.to_i
        ny   = node.y.to_i
        d    = Math.floor(node.weight - node.heuristic)

        if node.state == 3
          # If node is connected to target, exit
          dist = d + Math.abs(tx-nx) + Math.abs(ty-ny)
          target.pred = node
          break
        end

        # Mark node closed
        node.state = 4

        # Pop node from toVisit queue
        toVisit = pop(toVisit) # TODO: from Vertex

        adj = node.edges
        n   = adj.length
        n.times do |i|
          v = adj[i]
          state = v.state
          next if state == 4

          vd = d + Math.abs(nx-v.x) + Math.abs(ny-v.y)
          if state < 2
            vh      = heuristic(tdist, tx, ty, v)
            v.state    |= 2
            v.heuristic = vh
            v.weight    = vh + vd
            v.pred      = node
            toVisit     = push(toVisit, v) # TODO: from Vertex
            freeList    = insert(freeList, v) # TODO: from Vertex
          else
            vw = vd + v.heuristic
            if vw < v.weight
              v.weight   = vw
              v.pred     = node
              toVisit    = decreaseKey(toVisit, v) # TODO: from Vertex
            end
          end
        end
      end
    end

    # Clear the free list & priority queue
    clear(freeList) # TODO: from Vertex

    # Reset pointers
    @freeList = target
    @toVisit = NIL
    @lastS = @lastT = nil

    # Reset landmark distance
    NUM_LANDMARKS.times do |i|
      tdist[i] = Float::INFINITY
    end

    # Return target distance
    dist
  end
end
