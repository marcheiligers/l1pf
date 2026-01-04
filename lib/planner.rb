# 'use strict'

# var bsearch = require('binary-search-bounds')
# var createGeometry = require('./geometry')
# var Graph = require('./graph')

# TODO: namespace pollution - these constants should be namespaced (e.g., as class constants in PlannerBuilder)
LEAF_CUTOFF = 64
BUCKET_SIZE = 32

# module.exports = createPlanner

# TODO: namespace pollution - classes should be nested in a module (e.g., Planner::Leaf)
class Leaf
  attr_accessor :verts, :leaf

  def initialize(verts)
    @verts = verts
    @leaf = true
  end
end

# TODO: namespace pollution - Struct definitions should be namespaced or nested in a module
Bucket = Struct.new(:y0, :y1, :top, :bottom, :left, :right, :on)

Node = Struct.new(:x, :buckets, :left, :right)

class PlannerBuilder
  def initialize(grid)
    @geom = createGeometry(grid)
    @graph = Graph.new
    @verts = {}
    @edges = []
  end

  def build
    root = makeTree(@geom.corners, -Float::INFINITY, Float::INFINITY)

    # Link edges
    @edges.length.times do |i| # TODO: convert to while loop for performance: l = @edges.length; i = -1; while (i += 1) < l
      @graph.link(@verts[@edges[i][0]], @verts[@edges[i][1]])
    end

    # Initialize graph
    @graph.init

    # Return resulting planner
    L1PathPlanner.new(@geom, @graph, root)
  end

private

  def makeVertex(pair) # TODO: rename to make_vertex (snake_case convention)
    return nil unless pair
    return @verts[pair] if @verts[pair]

    @verts[pair] = @graph.vertex(pair[0], pair[1])
  end

  def makeLeaf(corners, x0, x1) # TODO: rename to make_leaf (snake_case convention)
    localVerts = [] # TODO: rename to local_verts (snake_case convention)
    corners.length.times do |i| # TODO: convert to while loop for performance: l = corners.length; i = -1; while (i += 1) < l
      u = corners[i]
      ux = @graph.vertex(u[0], u[1])
      localVerts.push(ux)
      @verts[u] = ux
      i.times do |j| # TODO: convert to while loop for performance: j = -1; while (j += 1) < i
        v = corners[j]
        @edges.push([u,v]) if !@geom.stabBox(u[0], u[1], v[0], v[1])
      end
    end

    Leaf.new(localVerts)
  end

  def makeBucket(corners, x) # TODO: rename to make_bucket (snake_case convention)
    # Split visible corners into 3 cases
    left  = []
    right = []
    on    = []
    corners.length.times do |i| # TODO: convert to while loop for performance: l = corners.length; i = -1; while (i += 1) < l
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
    loSteiner = add_steiner(x, on, y0, true) # TODO: rename to lo_steiner (snake_case convention)
    hiSteiner = add_steiner(x, on, y1, false) # TODO: rename to hi_steiner (snake_case convention)

    bipartite(left, right)
    bipartite(on, left)
    bipartite(on, right)

    # Connect vertical edges
    (1...on.length).each do |i|
      u = on[i-1]
      v = on[i]
      @edges.push([u,v]) if !@geom.stabBox(u[0], u[1], v[0], v[1])
    end

    {
      left:     left,
      right:    right,
      on:       on,
      steiner0: loSteiner,
      steiner1: hiSteiner,
      y0:       y0,
      y1:       y1
    }
  end

  def add_steiner(x, on, y, first)
    if !@geom.stabTile(x, y)
      on.length.times do |i| # TODO: convert to while loop for performance: l = on.length; i = -1; while (i += 1) < l
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
    a.length.times do |i| # TODO: convert to while loop for performance: l = a.length; i = -1; while (i += 1) < l
      u = a[i]
      b.length.times do |j| # TODO: convert to while loop for performance: bl = b.length; j = -1; while (j += 1) < bl
        v = b[j]
        @edges.push([u,v]) unless @geom.stabBox(u[0], u[1], v[0], v[1])
      end
    end
  end

  def comparePair(a, b) # TODO: rename to compare_pair (snake_case convention)
    d = a[1] - b[1]
    return d unless d == 0

    a[0] - b[0]
  end

  def makePartition(x, corners) # TODO: rename to make_partition (snake_case convention)
    left  = []
    right = []
    on    = []

    # Intersect rays along x horizontal line
    corners.length.times do |i| # TODO: convert to while loop for performance: l = corners.length; i = -1; while (i += 1) < l
      c = corners[i]
      on.push(c) if !@geom.stabRay(c[0], c[1], x)

      if c[0] < x
        left.push(c)
      elsif c[0] > x
        right.push(c)
      end
    end

    # Sort on events by y then x
    on.sort! { |a, b| comparePair(a, b) }

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

  def makeTree(corners, x0, x1) # TODO: rename to make_tree (snake_case convention)
    return nil if corners.length == 0
    return makeLeaf(corners, x0, x1) if corners.length < LEAF_CUTOFF

    x = corners[corners.length >> 1][0] # TODO: bitwise shift for division by 2 - is this the idiomatic Ruby way?
    partition = makePartition(x, corners)
    left      = makeTree(partition[:left], x0, x)
    right     = makeTree(partition[:right], x, x1)

    # Construct vertices
    partition[:on].length.times do |i| # TODO: convert to while loop for performance: l = partition[:on].length; i = -1; while (i += 1) < l
      @verts[partition[:on][i]] = @graph.vertex(partition[:on][i][0], partition[:on][i][1])
    end

    # Build buckets
    vis = partition[:vis]
    buckets = []
    lastSteiner = nil # TODO: rename to last_steiner (snake_case convention)
    i = 0
    while i < vis.length # TODO: already using while loop - good!
      v0 = i
      v1 = [i + BUCKET_SIZE - 1, vis.length - 1].min
      # Continue while next element exists and has same y coordinate
      while v1 + 1 < vis.length && vis[v1][1] == vis[v1 + 1][1]
        v1 += 1
      end

      i = v1 + 1
      slice_length = v1 - v0 + 1
      bb = makeBucket(vis.slice(v0, slice_length), x)
      if lastSteiner && bb[:steiner0] && !@geom.stabBox(lastSteiner[0], lastSteiner[1], bb[:steiner0][0], bb[:steiner0][1])
        @edges.push([lastSteiner, bb[:steiner0]])
      end
      lastSteiner = bb[:steiner1]
      buckets.push(Bucket.new(
        bb[:y0],
        bb[:y1],
        makeVertex(bb[:steiner0]),
        makeVertex(bb[:steiner1]),
        bb[:left].map { |v| makeVertex(v) },
        bb[:right].map { |v| makeVertex(v) },
        bb[:on].map { |v| makeVertex(v) }
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
      if !geom.stabBox(tx, ty, sx, sy)
        out.push(sx, sy) if out
        return 0
      end
      return Float::INFINITY
    end

    # Check easy case - s and t directly connected
    if !geom.stabBox(tx, ty, sx, sy)
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
    connectNodes(geom, @graph, @root, true, tx, ty)

    # Mark source
    connectNodes(geom, @graph, @root, false, sx, sy)

    # Run A*
    dist = @graph.search

    # Recover path
    @graph.get_path(out) if out && dist < Float::INFINITY

    dist
  end

private

  def compareBucket(bucket, y) # TODO: rename to compare_bucket (snake_case convention)
    bucket.y0 - y
  end

  def connectList(nodes, geom, graph, target, x, y) # TODO: rename to connect_list (snake_case convention)
    nodes.length.times do |i| # TODO: convert to while loop for performance: l = nodes.length; i = -1; while (i += 1) < l
      v = nodes[i]
      if !geom.stabBox(v.x, v.y, x, y)
        if target
          graph.add_t(v)
        else
          graph.add_s(v)
        end
      end
    end
  end

  def connectNodes(geom, graph, node, target, x, y) # TODO: rename to connect_nodes (snake_case convention)
    # Mark target nodes
    while node
      # Check leaf case
      if node.is_a?(Leaf)
        vv = node.verts
        vv.length.times do |i| # TODO: convert to while loop for performance: l = vv.length; i = -1; while (i += 1) < l
          v = vv[i]
          if !geom.stabBox(v.x, v.y, x, y)
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
      idx = BSearch.lt(buckets, y, method(:compareBucket))

      if idx >= 0
        bb = buckets[idx]
        if y < bb.y1
          # Common case:
          # Connect right
          connectList(bb.right, geom, graph, target, x, y) if node.x >= x
          # Connect left
          connectList(bb.left, geom, graph, target, x, y) if node.x <= x # TODO: check if this is correct, connecting both right and left if node.x == x
          # Connect on
          connectList(bb.on, geom, graph, target, x, y)
        else
          # Connect to bottom of bucket above
          v = buckets[idx].bottom
          if v && !geom.stabBox(v.x, v.y, x, y)
            if target
              graph.add_t(v)
            else
              graph.add_s(v)
            end
          end
          # Connect to top of bucket below
          if idx + 1 < buckets.length
            v = buckets[idx + 1].top
            if v && !geom.stabBox(v.x, v.y, x, y)
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
        if v && !geom.stabBox(v.x, v.y, x, y)
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

# TODO: namespace pollution - this is the main export, should be in a module (e.g., Planner.create or L1PathPlanner.create)
def createPlanner(grid) # TODO: rename to create_planner (snake_case convention)
  builder = PlannerBuilder.new(grid)
  builder.build
end
