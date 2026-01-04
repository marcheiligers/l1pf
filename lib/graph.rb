# 'use strict'

# module.exports = Graph

# var vtx = require('./vertex')
# var NIL = vtx.NIL
# var NUM_LANDMARKS = vtx.NUM_LANDMARKS
# var LANDMARK_DIST = vtx.LANDMARK_DIST

# TODO: namespace pollution - wrap in module or make this a class method of Graph
def heuristic(tdist, tx, ty, node)
  nx = node.x.to_i
  ny = node.y.to_i
  pi = (nx - tx).abs + (ny - ty).abs
  ndist = node.landmark
  NUM_LANDMARKS.times do |i| # TODO: convert to while loop for performance: l = NUM_LANDMARKS; i = -1; while (i += 1) < l
    pi = [pi, tdist[i] - ndist[i]].max
  end
  1.0000009536743164 * pi # TODO: this magic number seems very specific. what is it?
end

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
    @landmark_dist = Array.new(NUM_LANDMARKS, INFINITY) # copied from Vertex
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
      NUM_LANDMARKS.times do |i| # TODO: convert to while loop for performance: l = NUM_LANDMARKS; i = -1; while (i += 1) < l
        tdist[i] = [tdist[i], vdist[i] + d].min
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
    n.times do |i| # TODO: convert to while loop for performance: i = -1; while (i += 1) < n
      verts[i].component = -1
    end

    components = []
    n.times do |i| # TODO: convert to while loop for performance: i = -1; while (i += 1) < n
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
        adj.length.times do |j| # TODO: convert to while loop for performance: l = adj.length; j = -1; while (j += 1) < l
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

    NUM_LANDMARKS.times do |k| # TODO: convert to while loop for performance: l = NUM_LANDMARKS; k = -1; while (k += 1) < l
      v.weight = 0.0
      @landmarks.push(v)

      to_visit = v
      while to_visit != Vertex::NIL
        v = to_visit
        v.state = 2
        to_visit = Vertex.pop(to_visit)
        w = v.weight
        adj = v.edges

        adj.length.times do |i| # TODO: convert to while loop for performance: l = adj.length; i = -1; while (i += 1) < l
          u = adj[i]
          next if u.state == 2

          d = w + (v.x - u.x).abs + (v.y - u.y).abs
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
      component.length.times do |i| # TODO: convert to while loop for performance: l = component.length; i = -1; while (i += 1) < l
        u = component[i]
        u.state = 0
        u.landmark[k] = u.weight
        s = INFINITY
        k.times do |j| # TODO: convert to while loop for performance: j = -1; while (j += 1) < k
          s = [s, u.landmark[j]].min
        end
        if s > farthest_d
          v = u
          farthest_d = s
        end
      end
    end
  end

  def init
    find_components.each do |component|
      find_landmarks(component)
    end
  end

  # Runs a* on the graph
  def search
    target = @target
    free_list = @free_list
    tdist = @landmark_dist

    # Initialize target properties
    dist = INFINITY

    # Test for case where S and T are disconnected
    if @last_s && @last_t && @last_s.component == @last_t.component
      # sx = @src_x.to_i
      # sy = @src_y.to_i
      tx = @dst_x.to_i
      ty = @dst_y.to_i

      to_visit = @to_visit
      while to_visit != Vertex::NIL
        node = to_visit
        nx   = node.x.to_i
        ny   = node.y.to_i
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
        n.times do |i| # TODO: convert to while loop for performance: i = -1; while (i += 1) < n
          v = adj[i]
          state = v.state
          next if state == 4

          vd = d + (nx - v.x).abs + (ny - v.y).abs
          if state < 2
            vh      = heuristic(tdist, tx, ty, v)
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
    NUM_LANDMARKS.times do |i| # TODO: convert to while loop for performance: l = NUM_LANDMARKS; i = -1; while (i += 1) < l
      tdist[i] = INFINITY
    end

    # Return target distance
    dist
  end
end
