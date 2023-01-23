# 'use strict'

# var bsearch = require('binary-search-bounds')
# var createGeometry = require('./geometry')
# var Graph = require('./graph')

LEAF_CUTOFF = 64
BUCKET_SIZE = 32

# module.exports = createPlanner

class Leaf
  attr_accessor :verts, :leaf

  def initialize(verts)
    @verts = verts
    @leaf = true
  end
end

Bucket = Struct.new(:y0, :y1, :top, :bottom, :left, :right, :on)

Node = Struct.new(:x, :buckets, :left, :right)

class L1PathPlanner
  def initialize(geometry, graph, root)
    @geometry   = geometry
    @graph      = graph
    @root       = root
  end

  def search(tx, ty, sx, sy, out = nil)
    var geom = this.geometry

    # Degenerate case:  s and t are equal
    if tx === sx && ty === sy
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
      return Math.abs(tx-sx) + Math.abs(ty-sy)
    end

    # Prepare graph
    @graph.setSourceAndTarget(sx, sy, tx, ty)

    # Mark target
    connectNodes(geom, graph, this.root, true, tx, ty)

    # Mark source
    connectNodes(geom, graph, this.root, false, sx, sy)

    # Run A*
    dist = graph.search

    # Recover path
    graph.getPath(out) if out && dist < Float::INFINITY

    dist
  end

private

  def compareBucket(bucket, y)
    bucket.y0 - y
  end

  def connectList(nodes, geom, graph, target, x, y)
    nodes.length.times do |i|
      v = nodes[i]
      if !geom.stabBox(v.x, v.y, x, y)
        if target
          graph.addT(v)
        else
          graph.addS(v)
        end
      end
    end
  end

  def connectNodes(geom, graph, node, target, x, y)
    # Mark target nodes
    while node
      # Check leaf case
      if node.leaf
        vv = node.verts
        vv.length.times do |i|
          v = vv[i]
          if !geom.stabBox(v.x, v.y, x, y)
            if target
              graph.addT(v)
            else
              graph.addS(v)
            end
          end
        end
        break
      end

      # Otherwise, glue into buckets
      buckets = node.buckets
      idx = BSearch.lt(buckets, y, compareBucket)

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
              graph.addT(v)
            else
              graph.addS(v)
            end
          end
          # Connect to top of bucket below
          if idx + 1 < buckets.length
            v = buckets[idx + 1].top
            if v && !geom.stabBox(v.x, v.y, x, y)
              if target
                graph.addT(v)
              else
                graph.addS(v)
              end
            end
          end
        end
      else
        # Connect to top of box
        v = buckets[0].top
        if v && !geom.stabBox(v.x, v.y, x, y)
          if target
            graph.addT(v)
          else
            graph.addS(v)
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

  def comparePair(a, b)
    d = a[1] - b[1]
    return d unless d == 0

    a[0] - b[0]
  end

  def makePartition(x, corners, geom, edges)
    var left  = []
    var right = []
    var on    = []

    # Intersect rays along x horizontal line
    corners.length.times do |i|
      c = corners[i]
      on.push(c) if !geom.stabRay(c[0], c[1], x)

      if c[0] < x
        left.push(c)
      elsif c[0] > x
        right.push(c)
      end
    end

    # Sort on events by y then x
    on.sort(comparePair) # TODO: sorting function

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
        l = on[i+=1][0]
      end

      vis.push([l,y]) if l < x

      while i < on.length && on[i][1] == y && on[i][0] == x
        rem.push(on[i])
        vis.push(on[i])
        i += 1
      end

      if i < on.length && on[i][1] == y
        r = on[i++][0]
        while i < on.length && on[i][1] === y
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
end

def createPlanner(grid)
  geom = createGeometry(grid)
  graph = Graph.new
  verts = {}
  edges = []

  root = makeTree(geom.corners, -Float::INFINITY, Float::INFINITY)

  # Link edges
  edges.length.times do |i|
    graph.link(verts[edges[i][0]], verts[edges[i][1]])
  end

  # Initialized graph
  graph.init

  # Return resulting tree
  L1PathPlanner.new(geom, graph, root)
end

def makeVertex(pair)
  return nil unless pair
  return res if verts[pair]

  verts[pair] = graph.vertex(pair[0], pair[1])
end

def makeLeaf(corners, x0, x1)
  localVerts = []
  corners.length.times do |i|
    u = corners[i]
    ux = graph.vertex(u[0], u[1])
    localVerts.push(ux)
    verts[u] = ux
    i.times do |j|
      v = corners[j]
      edges.push([u,v]) if !geom.stabBox(u[0], u[1], v[0], v[1])
    end
  end

  Leaf.new(localVerts)
end

def makeBucket(corners, x)
  # Split visible corners into 3 cases
  left  = []
  right = []
  on    = []
  corners.length.times do |i|
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
  loSteiner = addSteiner(y0, true)
  hiSteiner = addSteiner(y1, false)

  bipartite(left, right)
  bipartite(on, left)
  bipartite(on, right)

  # Connect vertical edges
  on.length.times do |i|
    u = on[i-1]
    v = on[i]
    edges.push([u,v]) if !geom.stabBox(u[0], u[1], v[0], v[1])
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

# Add Steiner vertices if needed
# TODO: this function is relying on some external vars -- x, on
def addSteiner(y, first)
  if !geom.stabTile(x, y)
    on.length.times do |i|
      return on[i] if on[i][0] == x && on[i][1] == y
    end

    pair = [x, y]
    if first
      on.unshift(pair)
    else
      on.push(pair)
    end

    verts[pair] = graph.vertex(x,y) unless verts[pair]
    return pair
  end

  nil
end

def bipartite(a, b)
  a.length.times do |i|
    u = a[i]
    b.length.times do |j|
      v = b[j]
      edges.push([u,v]) unless geom.stabBox(u[0], u[1], v[0], v[1])
    end
  end
end

# Make tree
def makeTree(corners, x0, x1)
  return nil if corners.length == 0
  return makeLeaf(corners, x0, x1) if corners.length < LEAF_CUTOFF

  x = corners[corners.length >> 1][0]
  partition = makePartition(x, corners, geom, edges)
  left      = makeTree(partition.left, x0, x)
  right     = makeTree(partition.right, x, x1)

  # Construct vertices
  partition.on.length.times do |i|
    verts[partition.on[i]] = graph.vertex(partition.on[i][0], partition.on[i][1])
  end

  # Build buckets
  vis = partition.vis
  buckets = []
  lastSteiner = null
  i = 0
  while i < vis.length
    v0 = i
    v1 = Math.min(i + BUCKET_SIZE - 1, vis.length - 1)
    # TODO: ensure this line works as advertised
    # while(++v1 < vis.length && vis[v1-1][1] === vis[v1][1]) {}
    loop do
      v1 += 1
      break if v1 < vis.length && vis[v1-1][1] == vis[v1][1]
    end

    i = v1
    bb = makeBucket(vis.slice(v0, v1), x)
    if lastSteiner && bb.steiner0 && !geom.stabBox(lastSteiner[0], lastSteiner[1], bb.steiner0[0], bb.steiner0[1])
      edges.push([lastSteiner, bb.steiner0])
    end
    lastSteiner = bb.steiner1
    buckets.push(Bucket.new(
      bb.y0,
      bb.y1,
      makeVertex(bb.steiner0),
      makeVertex(bb.steiner1),
      bb.left.map(makeVertex),
      bb.right.map(makeVertex),
      bb.on.map(makeVertex)
    ))
  end
  Node.new(x, buckets, left, right)
end
