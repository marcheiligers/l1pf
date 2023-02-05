# var vtx = require('../lib/vertex')

# function V(v) {
#   return [v.x, v.y]
# }

# function checkDefaultGraphInvariant(t, graph) {
#   t.equals(graph.toVisit, vtx.NIL, 'heap empty')
#   t.equals(graph.freeList, graph.target, 'target head of freelist')

#   t.equals(graph.target.left, vtx.NIL, 'target left clear')
#   t.equals(graph.target.right, vtx.NIL, 'target right clear')
#   t.equals(graph.target.parent, vtx.NIL, 'target parent clear')
#   t.equals(graph.target.state, 0, 'target state clear')
#   t.equals(graph.target.nextFree, null, 'target nextFree null')
#   t.same(graph.target.edges, [], 'target edges empty')

#   graph.verts.forEach(function(v, i) {
#     //Check topology
#     v.edges.forEach(function(u, j) {
#       var v_idx = u.edges.indexOf(v)
#       t.ok(v_idx >= 0, 'vertex ' + V(v) + ' linked to ' + V(u))
#     })

#     t.equals(v.left, vtx.NIL, 'left clear')
#     t.equals(v.right, vtx.NIL, 'right clear')
#     t.equals(v.parent, vtx.NIL, 'parent clear')
#     t.ok(!v.target, 'not target')
#     t.equals(v.state, 0, 'state ok')
#     t.equals(v.nextFree, null, 'free list empty')
#   })
# }

# function V(v) {
#   return [v.x, v.y]
# }

def graph_check_default_graph_invariant(assert, graph)
  assert.equal!(graph.to_visit, Vertex::NIL, 'heap is not empty')
  assert.equal!(graph.free_list, graph.target, 'target is not head of freelist')

  assert.equal!(graph.target.left, Vertex::NIL, 'target left is not clear')
  assert.equal!(graph.target.right, Vertex::NIL, 'target right is not clear')
  assert.equal!(graph.target.parent, Vertex::NIL, 'target parent is not clear')
  assert.equal!(graph.target.state, 0, 'target state is not clear')
  assert.equal!(graph.target.next_free, nil, 'target next_free is not null')
  assert.equal!(graph.target.edges, [], 'target edges is not empty')

  graph.verts.each.with_index do |v, i|
    # Check topology
    v.edges.each.with_index do |u, j|
      v_idx = u.edges.index(v)
      t.true!(v_idx >= 0, "vertex #{[v.x, v.y]} not linked to #{[u.x, u.y]}")
    end

    assert.equal!(v.left, Vertex::NIL, 'left is not clear')
    assert.equal!(v.right, Vertex::NIL, 'right is not clear')
    assert.equal!(v.parent, Vertex::NIL, 'parent is not clear')
    # assert.true!(!v.target, '!not target') # I wonder if this was intended to be a type check
    assert.equal!(v.state, 0, 'state is not ok')
    assert.equal!(v.next_free, nil, 'free list is not empty')
  end
end

# var tape = require('tape')
# var vtx = require('../lib/vertex')
# var Graph = require('../lib/graph')

# var checkDefaultGraphInvariant = require('./graph-invariant')

def test_graph_a_star_singleton(_args, assert)
  g = Graph.new
  v = g.vertex(0, 0)

  g.init
  graph_check_default_graph_invariant(assert, g)

  g.set_source_and_target(-1, -1, 1, 1)
  g.add_t(v)
  assert.equal!(v.state, 1, 'target')

  g.add_s(v)
  assert.equal!(v.state, 3, 'v active')

  assert.equal!(g.search(), 4, 'distance ok')

  g.get_path([])

  graph_check_default_graph_invariant(assert, g)

  g.set_source_and_target(-1, -1, 1, 1)
  g.add_s(v)
  assert.equal!(v.state, 2, 'v active')

  assert.equal!(g.search, INFINITY, 'disconnected')

  graph_check_default_graph_invariant(assert, g)
end

def test_graph_a_star_grid(_args, assert)
  g = Graph.new
  verts = []

  11.times do |i|
    row = verts[i] = []
    11.times do |j|
      row[j] = g.vertex(i, j)
    end
  end

  # Link edges
  10.times do |i|
    10.times do |j|
      g.link(verts[i][j], verts[i+1][j])
      g.link(verts[i][j], verts[i][j+1])
    end
  end

  g.init
  graph_check_default_graph_invariant(assert, g)

  # Run a series of random tests
  100.times do |i|
    sx = rand(10)
    sy = rand(10)
    tx = rand(10)
    ty = rand(10)

    g.set_source_and_target(sx,sy, tx,ty)

    g.add_t(verts[tx][ty])
    assert.true!(verts[tx][ty].state & 1, 'target is not ok')
    g.add_s(verts[sx][sy])
    assert.true!(verts[sx][sy].state & 2, 'v is not active')

    assert.equal!(g.search(), (sx - tx).abs + (sy - ty).abs, 'dist is not ok')
    graph_check_default_graph_invariant(assert, g)

    path = g.getPath([])
    assert.true!(path.length >= 2)
    assert.equal!(path[0], tx, 'path end x is not ok')
    assert.equal!(path[1], ty, 'path end y is not ok')

    nn = 1
    while 2 * (nn + 1) < path.length
      exp = (path[2 * nn] - path[2 * nn - 2]).abs + (path[2 * nn + 1] - path[2 * nn - 1]).abs
      assert.equal!(exp, 1, 'step is not ok')
      nn += 1
    end

    assert.equal!(path[path.length-2], sx, 'path start x is not ok')
    assert.equal!(path[path.length-1], sy, 'path start y is not ok')
  end
end
