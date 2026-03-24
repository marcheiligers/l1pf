def test_vertex_free_list(_args, assert)
  list = nil

  # Try inserting elements into the list
  items = []
  100.times do |i|
    v = Vertex.create(i, i)
    v.state = i
    items.push(v)
    list = Vertex.insert(list, v)
  end

  # Check list state
  head = list
  99.downto(0) do |i|
    assert.equal!(head, items[i])
    head = head.next_free
  end
  assert.true!(head.nil?)
end

# tape('topology - vertex', function(t) {

#   var verts = []
#   for(var i=0; i<10; ++i) {
#     verts.push(vtx.create(i,i))
#   }

#   for(var i=0; i<10; ++i) {
#     var v = verts[i]
#     for(var j=1+i; j<10; j+=(i+1)) {
#       var u = verts[j]
#       vtx.link(u, v)
#     }
#   }

#   for(var i=0; i<10; ++i) {
#     var v = verts[i]
#     for(var j=1+i; j<10; j+=(i+1)) {
#       var u = verts[j]
#       var v_idx = v.edges.indexOf(u)
#       var u_idx = u.edges.indexOf(v)
#       t.equals(v.edges[v_idx], u)
#       t.equals(u.edges[u_idx], v)
#     }
#   }

#   t.end()
# })

def test_vertext_topology(_args, assert)
  verts = []
  10.times do |i|
    verts.push(Vertex.create(i, i))
  end

  10.times do |i|
    v = verts[i]
    j = 1 + i
    while j < 10
      u = verts[j]
      Vertex.link(u, v)
      j += i + 1
    end
  end

  10.times do |i|
    v = verts[i]
    j = 1 + i
    while j < 10
      u = verts[j]
      v_idx = v.edges.index(u)
      u_idx = u.edges.index(v)
      assert.equal!(v.edges[v_idx], u)
      assert.equal!(u.edges[u_idx], v)
      j += i + 1
    end
  end
end

# var pq = require('../lib/vertex')

# function checkHeapInvariant(t, root) {
#   t.equals(pq.NIL.left, pq.NIL, 'nil left ok')
#   t.equals(pq.NIL.right, pq.NIL, 'nil right ok')
#   //Allow for parent of NIL to be modified
#   function checkNode(node, parent, leader) {
#     if(node === pq.NIL) {
#       return
#     }
#     t.equals(node.parent, parent, 'parent ok')
#     if(leader !== pq.NIL) {
#       t.ok(leader.weight < node.weight, 'weight ok')
#     }
#     checkNode(node.left, node, node)
#     checkNode(node.right, node, leader)
#   }
#   checkNode(root, pq.NIL, pq.NIL)
# }

# tape('pairing heap fuzz test', function(t) {
#   var items = []
#   var root = pq.NIL

#   for(var i=0; i<100; ++i) {
#     var w = Math.random()
#     var node = pq.create(0, 0)
#     node.weight = w

#     items.push(node)
#     root = pq.push(root, node)

#     checkHeapInvariant(t, root)
#   }

#   //Try randomly decreasing keys
#   for(var i=0; i<200; ++i) {
#     var j = (Math.random()*100)|0
#     var node = items[j]
#     node.weight -= Math.random()
#     root = pq.decreaseKey(root, node)

#     checkHeapInvariant(t, root)
#   }

#   items.sort(function(a,b) {
#     return a.weight - b.weight
#   })

#   while(items.length > 0) {
#     var node = items.shift()
#     t.equals(node, root, 'items in order: ' + node.weight + ' = ' + root.weight)
#     root = pq.pop(root)
#     checkHeapInvariant(t, root)
#   }

#   t.end()
# })

def vertex_check_heap_invariant(assert, root)
  assert.equal!(Vertex::NIL.left, Vertex::NIL, 'Vertex::NIL.left is not Vertex::NIL')
  assert.equal!(Vertex::NIL.right, Vertex::NIL, 'Vertex::NIL.right is not Vertex::NIL')

  vertex_check_node(assert, root, Vertex::NIL, Vertex::NIL)
end

# Allow for parent of NIL to be modified
def vertex_check_node(assert, node, parent, leader)
  return if node == Vertex::NIL

  assert.equal!(node.parent, parent, 'Parent not ok')
  if leader != Vertex::NIL
    assert.true!(leader.weight < node.weight, 'Weight not ok')
  end

  vertex_check_node(assert, node.left, node, node)
  vertex_check_node(assert, node.right, node, leader)
end

def test_vertex_pairing_heap_fuzz_test(_args, assert)
  items = []
  root = Vertex::NIL

  100.times do |i|
    w = rand
    node = Vertex.create(0, 0)
    node.weight = w

    items.push(node)
    root = Vertex.push(root, node)

    vertex_check_heap_invariant(assert, root)
  end

  # Try randomly decreasing keys
  200.times do |i|
    j = rand(100)
    node = items[j]
    node.weight -= rand
    root = Vertex.decrease_key(root, node)

    vertex_check_heap_invariant(assert, root)
  end

  items = items.sort_by(&:weight)

  while items.length > 0
    node = items.shift
    assert.equal!(node, root, "Items not in order: #{node.weight} = #{root.weight}")
    root = Vertex.pop(root)
    vertex_check_heap_invariant(assert, root)
  end
end
