# 'use strict'

# var bsearch = require('binary-search-bounds')
# var createGeometry = require('./geometry')
# var Graph = require('./graph')

# module.exports = createPlanner

module Planner
class Leaf
  attr_accessor :verts, :leaf

  def initialize(verts)
    @verts = verts
    @leaf = true
  end
end

Bucket = Struct.new(:y0, :y1, :top, :bottom, :left, :right, :on)

Node = Struct.new(:x, :buckets, :left, :right)

class PlannerBuilder
  LEAF_CUTOFF = 64
  BUCKET_SIZE = 32
  def initialize(grid)
    @geom = Geometry.create_geometry(grid)
    @graph = Graph.new
    @verts = {}
    @edges = []
  end

  def build
    root = make_tree(@geom.corners, -Float::INFINITY, Float::INFINITY)

    # Link edges
    l = @edges.length
    i = -1
    while (i += 1) < l
      @graph.link(@verts[@edges[i][0]], @verts[@edges[i][1]])
    end

    # Initialize graph
    @graph.init

    # Return resulting planner
    L1PathPlanner.new(@geom, @graph, root)
  end

private

  def make_vertex(pair)
    return nil unless pair
    return @verts[pair] if @verts[pair]

    @verts[pair] = @graph.vertex(pair[0], pair[1])
  end

  def make_leaf(corners, x0, x1)
    local_verts = []
    l = corners.length
    i = -1
    while (i += 1) < l
      u = corners[i]
      ux = @graph.vertex(u[0], u[1])
      local_verts.push(ux)
      @verts[u] = ux
      j = -1
      while (j += 1) < i
        v = corners[j]
        @edges.push([u,v]) if !@geom.stab_box(u[0], u[1], v[0], v[1])
      end
    end

    Leaf.new(local_verts)
  end

  def make_bucket(corners, x)
    # Split visible corners into 3 cases
    left  = []
    right = []
    on    = []
    l = corners.length
    i = -1
    while (i += 1) < l
      if corners[i][0] < x
        left.push(corners[i])
      elsif(corners[i][0] > x)
        right.push(corners[i])
      else
        on.push(corners[i])
      end
    end

    y0 = corners[0][1]
    y1 = corners[corners.length-1][1]
    lo_steiner = add_steiner(x, on, y0, true)
    hi_steiner = add_steiner(x, on, y1, false)

    bipartite(left, right)
    bipartite(on, left)
    bipartite(on, right)

    # Connect vertical edges
    i = 0
    while (i += 1) < on.length
      u = on[i-1]
      v = on[i]
      @edges.push([u,v]) if !@geom.stab_box(u[0], u[1], v[0], v[1])
    end

    {
      left:     left,
      right:    right,
      on:       on,
      steiner0: lo_steiner,
      steiner1: hi_steiner,
      y0:       y0,
      y1:       y1
    }
  end

  def add_steiner(x, on, y, first)
    if !@geom.stab_tile(x, y)
      l = on.length
      i = -1
      while (i += 1) < l
        return on[i] if on[i][0] == x && on[i][1] == y
      end

      pair = [x, y]
      if first # TODO: verify the semantics of first - should it be at the beginning or end of the array?
        on.unshift(pair)
      else
        on.push(pair)
      end

      @verts[pair] = @graph.vertex(x,y) unless @verts[pair]
      return pair
    end

    nil
  end

  def bipartite(a, b)
    l = a.length
    i = -1
    while (i += 1) < l
      u = a[i]
      bl = b.length
      j = -1
      while (j += 1) < bl
        v = b[j]
        @edges.push([u,v]) unless @geom.stab_box(u[0], u[1], v[0], v[1])
      end
    end
  end

  def compare_pair(a, b)
    d = a[1] - b[1]
    return d unless d == 0

    a[0] - b[0]
  end

  def make_partition(x, corners)
    left  = []
    right = []
    on    = []

    # Intersect rays along x horizontal line
    l = corners.length
    i = -1
    while (i += 1) < l
      c = corners[i]
      on.push(c) if !@geom.stab_ray(c[0], c[1], x)

      if c[0] < x
        left.push(c)
      elsif c[0] > x
        right.push(c)
      end
    end

    # Sort on events by y then x
    on.sort! { |a, b| compare_pair(a, b) }

    # Construct vertices and horizontal edges
    vis = []
    rem = []
    i = 0
    while i < on.length
      l = x
      r = x
      v = on[i]
      y = v[1]

      while i < on.length && on[i][1] == y && on[i][0] < x
        l = on[i][0]
        i += 1
      end

      vis.push([l,y]) if l < x

      while i < on.length && on[i][1] == y && on[i][0] == x
        rem.push(on[i])
        vis.push(on[i])
        i += 1
      end

      if i < on.length && on[i][1] == y
        r = on[i][0]
        i += 1
        while i < on.length && on[i][1] == y
          i += 1
        end
      end

      vis.push([r,y]) if r > x
    end

    {
      x:       x,
      left:    left,
      right:   right,
      on:      rem,
      vis:     vis
    }
  end

  def make_tree(corners, x0, x1)
    return nil if corners.length == 0
    return make_leaf(corners, x0, x1) if corners.length < LEAF_CUTOFF

    x = corners[corners.length >> 1][0] # TODO: bitwise shift for division by 2 - is this the idiomatic Ruby way?
    partition = make_partition(x, corners)
    left      = make_tree(partition[:left], x0, x)
    right     = make_tree(partition[:right], x, x1)

    # Construct vertices
    l = partition[:on].length
    i = -1
    while (i += 1) < l
      @verts[partition[:on][i]] = @graph.vertex(partition[:on][i][0], partition[:on][i][1])
    end

    # Build buckets
    vis = partition[:vis]
    buckets = []
    last_steiner = nil
    i = 0
    l = vis.length
    while i < l
      v0 = i
      v1 = (i + BUCKET_SIZE - 1).lesser(l - 1)
      # Continue while next element exists and has same y coordinate
      while v1 + 1 < l && vis[v1][1] == vis[v1 + 1][1]
        v1 += 1
      end

      i = v1 + 1
      slice_length = v1 - v0 + 1
      bb = make_bucket(vis.slice(v0, slice_length), x)
      if last_steiner && bb[:steiner0] && !@geom.stab_box(last_steiner[0], last_steiner[1], bb[:steiner0][0], bb[:steiner0][1])
        @edges.push([last_steiner, bb[:steiner0]])
      end
      last_steiner = bb[:steiner1]
      buckets.push(Bucket.new(
        bb[:y0],
        bb[:y1],
        make_vertex(bb[:steiner0]),
        make_vertex(bb[:steiner1]),
        bb[:left].map { |v| make_vertex(v) },
        bb[:right].map { |v| make_vertex(v) },
        bb[:on].map { |v| make_vertex(v) }
      ))
    end
    Node.new(x, buckets, left, right)
  end
end

class L1PathPlanner
  def initialize(geometry, graph, root)
    @geometry   = geometry
    @graph      = graph
    @root       = root
  end

  def search(tx, ty, sx, sy, out = nil)
    geom = @geometry

    # Degenerate case:  s and t are equal
    if tx == sx && ty == sy
      if !geom.stab_box(tx, ty, sx, sy)
        out.push(sx, sy) if out
        return 0
      end
      return Float::INFINITY
    end

    # Check easy case - s and t directly connected
    if !geom.stab_box(tx, ty, sx, sy)
      if out
        if sx != tx && sy != ty
          out.push(tx, ty, sx, ty, sx, sy)
        else
          out.push(tx, ty, sx, sy)
        end
      end
      return (tx-sx).abs + (ty-sy).abs
    end

    # Prepare graph
    @graph.set_source_and_target(sx, sy, tx, ty)

    # Mark target
    connect_nodes(geom, @graph, @root, true, tx, ty)

    # Mark source
    connect_nodes(geom, @graph, @root, false, sx, sy)

    # Run A*
    dist = @graph.search

    # Recover path
    @graph.get_path(out) if out && dist < Float::INFINITY

    dist
  end

private

  def compare_bucket(bucket, y)
    bucket.y0 - y
  end

  def connect_list(nodes, geom, graph, target, x, y)
    l = nodes.length
    i = -1
    while (i += 1) < l
      v = nodes[i]
      if !geom.stab_box(v.x, v.y, x, y)
        if target
          graph.add_t(v)
        else
          graph.add_s(v)
        end
      end
    end
  end

  def connect_nodes(geom, graph, node, target, x, y)
    # Mark target nodes
    while node
      # Check leaf case
      if node.is_a?(Leaf)
        vv = node.verts
        l = vv.length
        i = -1
        while (i += 1) < l
          v = vv[i]
          if !geom.stab_box(v.x, v.y, x, y)
            if target
              graph.add_t(v)
            else
              graph.add_s(v)
            end
          end
        end
        break
      end

      # Otherwise, glue into buckets
      buckets = node.buckets
      idx = BSearch.lt(buckets, y, method(:compare_bucket))

      if idx >= 0
        bb = buckets[idx]
        if y < bb.y1
          # Common case:
          # Connect right
          connect_list(bb.right, geom, graph, target, x, y) if node.x >= x
          # Connect left
          connect_list(bb.left, geom, graph, target, x, y) if node.x <= x # TODO: check if this is correct, connecting both right and left if node.x == x
          # Connect on
          connect_list(bb.on, geom, graph, target, x, y)
        else
          # Connect to bottom of bucket above
          v = buckets[idx].bottom
          if v && !geom.stab_box(v.x, v.y, x, y)
            if target
              graph.add_t(v)
            else
              graph.add_s(v)
            end
          end
          # Connect to top of bucket below
          if idx + 1 < buckets.length
            v = buckets[idx + 1].top
            if v && !geom.stab_box(v.x, v.y, x, y)
              if target
                graph.add_t(v)
              else
                graph.add_s(v)
              end
            end
          end
        end
      else
        # Connect to top of box
        v = buckets[0].top
        if v && !geom.stab_box(v.x, v.y, x, y)
          if target
            graph.add_t(v)
          else
            graph.add_s(v)
          end
        end
      end

      if node.x > x
        node = node.left
      elsif node.x < x
        node = node.right
      else
        break
      end
    end
  end
end

def self.create(grid)
  builder = PlannerBuilder.new(grid)
  builder.build
end
end
