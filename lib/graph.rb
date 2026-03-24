# 'use strict'

# module.exports = Graph

# var vtx = require('./vertex')
# var NIL = vtx.NIL
# var NUM_LANDMARKS = vtx.NUM_LANDMARKS
# var LANDMARK_DIST = vtx.LANDMARK_DIST

class Graph
  attr_reader :target, :verts, :free_list, :to_visit, :last_s, :last_t,
              :src_x, :src_y, :dst_x, :dst_y, :landmarks, :landmark_dist

  def initialize
    @target   = Vertex.create(0, 0) # TODO: why does Vertex have a create method?
    @verts    = []
    @free_list = @target
    @to_visit  = Vertex::NIL
    @last_s    = nil
    @last_t    = nil
    @src_x     = 0
    @src_y     = 0
    @dst_x     = 0
    @dst_y     = 0
    @landmarks = []
    @landmark_dist = Array.new(Vertex::NUM_LANDMARKS, Vertex::INFINITY) # copied from Vertex
  end

  def vertex(x, y)
    v = Vertex.create(x, y)
    @verts.push(v)
    v
  end

  def link(u, v)
    Vertex.link(u, v)
  end

  def set_source_and_target(sx, sy, tx, ty)
    @src_x = sx.to_i
    @src_y = sy.to_i
    @dst_x = tx.to_i
    @dst_y = ty.to_i
  end

  # Mark vertex connected to source
  def add_s(v)
    if (v.state & 2) == 0
      v.heuristic   = heuristic(@landmark_dist, @dst_x, @dst_y, v)
      v.weight      = (@src_x - v.x).abs + (@src_y - v.y).abs + v.heuristic
      v.state       |= 2
      v.pred        = nil
      @to_visit  = Vertex.push(@to_visit, v)
      @free_list = Vertex.insert(@free_list, v)
      @last_s    = v
    end
  end

  # Mark vertex connected to target
  def add_t(v)
    if (v.state & 1) == 0
      v.state |= 1
      @free_list = Vertex.insert(@free_list, v)
      @last_t = v

      # Update heuristic
      d = (v.x - @dst_x).abs + (v.y - @dst_y).abs
      vdist = v.landmark
      tdist = @landmark_dist
      l = Vertex::NUM_LANDMARKS
      i = -1
      while (i += 1) < l
        t = vdist[i] + d
        tdist[i] = tdist[i] < t ? tdist[i] : t
      end
    end
  end

  # Retrieves the path from dst->src
  def get_path(out)
    prev_x = @dst_x
    prev_y = @dst_y
    out.push(prev_x, prev_y)
    head = @target.pred

    while head
      out.push(head.x, prev_y) if prev_x != head.x && prev_y != head.y
      out.push(head.x, head.y) if prev_x != head.x || prev_y != head.y

      prev_x = head.x
      prev_y = head.y
      head = head.pred
    end

    out.push(@src_x, prev_y) if prev_x != @src_x && prev_y != @src_y
    out.push(@src_x, @src_y) if prev_x != @src_x || prev_y != @src_y
    out
  end

  def find_components
    verts = @verts
    n = verts.length
    i = -1
    while (i += 1) < n
      verts[i].component = -1
    end

    components = []
    i = -1
    while (i += 1) < n
      root = verts[i]
      next if root.component >= 0

      label = components.length
      root.component = label
      to_visit = [root]
      ptr = 0

      while ptr < to_visit.length
        v = to_visit[ptr]
        ptr += 1
        adj = v.edges
        l = adj.length
        j = -1
        while (j += 1) < l
          u = adj[j]
          next if u.component >= 0
          u.component = label
          to_visit.push(u)
        end
      end

      components.push(to_visit)
    end

    components
  end

  # Find all landmarks
  # For each connected component compute a set of landmarks
  def find_landmarks(unsorted_component)
    component = unsorted_component.sort do |a, b|
      d = a.x - b.x
      d == 0 ? a.y - b.y : d
    end

    v = component[component.length >> 1] # TODO: bitwise shift for division by 2 - is this the idiomatic Ruby way?

    l = Vertex::NUM_LANDMARKS
    k = -1
    while (k += 1) < l
      v.weight = 0.0
      @landmarks.push(v)

      to_visit = v
      while to_visit != Vertex::NIL
        v = to_visit
        v.state = 2
        to_visit = Vertex.pop(to_visit)
        w = v.weight
        vx = v.x
        vy = v.y
        adj = v.edges

        al = adj.length
        i = -1
        while (i += 1) < al
          u = adj[i]
          next if u.state == 2

          d = w + (vx - u.x).abs + (vy - u.y).abs
          if u.state == 0
            u.state = 1
            u.weight = d
            to_visit = Vertex.push(to_visit, u)
          elsif d < u.weight
            u.weight = d
            to_visit = Vertex.decrease_key(to_visit, u)
          end
        end
      end

      farthest_d = 0
      cl = component.length
      i = -1
      while (i += 1) < cl
        u = component[i]
        u.state = 0
        u.landmark[k] = u.weight
        s = Vertex::INFINITY
        j = -1
        while (j += 1) < k
          lj = u.landmark[j]
          s = s < lj ? s : lj
        end
        if s > farthest_d
          v = u
          farthest_d = s
        end
      end
    end
  end

  def init
    components = find_components
    i = -1
    l = components.length
    while (i += 1) < l
      find_landmarks(components[i])
    end
  end

  # Runs a* on the graph
  def search
    target = @target
    free_list = @free_list
    tdist = @landmark_dist

    # Initialize target properties
    dist = Vertex::INFINITY

    # Test for case where S and T are disconnected
    if @last_s && @last_t && @last_s.component == @last_t.component
      # sx = @src_x.to_i
      # sy = @src_y.to_i
      tx = @dst_x
      ty = @dst_y

      to_visit = @to_visit
      while to_visit != Vertex::NIL
        node = to_visit
        nx   = node.x
        ny   = node.y
        d    = (node.weight - node.heuristic).floor

        if node.state == 3
          # If node is connected to target, exit
          dist = d + (tx - nx).abs + (ty - ny).abs
          target.pred = node
          break
        end

        # Mark node closed
        node.state = 4

        # Pop node from to_visit queue
        to_visit = Vertex.pop(to_visit)

        adj = node.edges
        n   = adj.length
        i = -1
        while (i += 1) < n
          v = adj[i]
          state = v.state
          next if state == 4

          vx = v.x
          vy = v.y
          vd = d + (nx - vx).abs + (ny - vy).abs
          if state < 2
            # Inline heuristic
            vh = (vx - tx).abs + (vy - ty).abs
            ndist = v.landmark
            hi = -1
            while (hi += 1) < Vertex::NUM_LANDMARKS
              hd = tdist[hi] - ndist[hi]
              vh = hd > vh ? hd : vh
            end
            vh = 1.0000009536743164 * vh
            v.state    |= 2
            v.heuristic = vh
            v.weight    = vh + vd
            v.pred      = node
            to_visit     = Vertex.push(to_visit, v)
            free_list    = Vertex.insert(free_list, v)
          else
            vw = vd + v.heuristic
            if vw < v.weight
              v.weight   = vw
              v.pred     = node
              to_visit    = Vertex.decrease_key(to_visit, v)
            end
          end
        end
      end
    end

    # Clear the free list & priority queue
    Vertex.clear(free_list)

    # Reset pointers
    @free_list = target
    @to_visit = Vertex::NIL
    @last_s = @last_t = nil

    # Reset landmark distance
    l = Vertex::NUM_LANDMARKS
    i = -1
    while (i += 1) < l
      tdist[i] = Vertex::INFINITY
    end

    # Return target distance
    dist
  end

private

  def heuristic(tdist, tx, ty, node)
    pi = (node.x - tx).abs + (node.y - ty).abs
    ndist = node.landmark
    i = -1
    while (i += 1) < Vertex::NUM_LANDMARKS
      d = tdist[i] - ndist[i]
      pi = d > pi ? d : pi
    end
    1.0000009536743164 * pi # TODO: this magic number seems very specific. what is it?
  end
end
