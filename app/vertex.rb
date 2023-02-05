NUM_LANDMARKS = 16

INFINITY = Float::INFINITY
LANDMARK_DIST = Array.new(NUM_LANDMARKS, INFINITY)

# Vertices have to do multiple things
#
#   1.  They store the topology of the graph which is gonna get searched
#   2.  They implement the pairing heap data sturcture (intrusively)
#   3.  They implement a linked list for tracking clean up
#   4.  Track search information (keep track of predecessors, distances, open state)
#

class Vertex
  attr_accessor :x, :y, :heuristic, :weight, :left, :right, :parent,
                :next_free, :state, :pred, :edges, :landmark, :component

  class << self
    # Heap insertion
    def merge_link(a, b) # aka link, but addEdge is exported as link
      al = a.left
      b.right = al
      al.parent = b
      b.parent = a
      a.left = b
      a.right = NIL

      a
    end

    def merge(a, b)
      if a == NIL
        b
      elsif b == NIL
        a
      elsif a.weight < b.weight
        merge_link(a, b)
      else
        merge_link(b, a)
      end
    end

    # Topology
    def create(x, y) # createVertex
      result = Vertex.new(x, y)
      result.left = result.right = result.parent = NIL
      result
    end

    def link(u, v) # addEdge, see also merge_link
      u.edges.push(v)
      v.edges.push(u)
    end

    # Free list functions
    def insert(list, node) # aka pushList
      return list if(node.next_free)

      node.next_free = list
      node
    end

    def clear(v) # clearList
      while v
        var nxt = v.next_free
        v.state = 0
        v.left = v.right = v.parent = NIL
        v.next_free = null
        v = nxt
      end
    end

    def push(root, node) # heapPush
      if root == NIL
        node
      elsif(root.weight < node.weight)
        l = root.left
        node.right = l
        l.parent = node
        node.parent = root
        root.left = node

        root
      else
        l = node.left
        root.right = l
        l.parent = root
        root.parent = node
        node.left = root

        node
      end
    end

    def decrease_key(root, p) # decreaseKey
      q = p.parent
      return root if q.weight < p.weight

      r = p.right
      r.parent = q
      if q.left == p
        q.left = r
      else
        q.right = r
      end

      if root.weight <= p.weight
        l = root.left
        l.parent = p
        p.right = l
        root.left = p
        p.parent = root

        root
      else
        l = p.left
        root.right = l
        l.parent = root
        p.left = root
        root.parent = p
        p.right = p.parent = NIL

        p
      end
    end

    def pop(root) # takeMin
      p = root.left
      root.left = NIL
      root = p

      loop do
        q = root.right
        break if q == NIL

        p = root
        r = q.right
        s = merge(p, q)
        root = s

        loop do
          p = r
          q = r.right
          break if q == NIL

          r = q.right
          s = s.right = merge(p, q)
        end

        s.right = NIL
        if p != NIL
          p.right = root
          root = p
        end
      end

      root.parent = NIL
      root
    end
  end

  def initialize(x, y)
    # User data
    @x        = x
    @y        = y

    # Priority queue info
    @heuristic = 0.25
    @weight    = 0.25
    @left      = nil
    @right     = nil
    @parent    = nil

    # Visit tags
    @state    = 0
    @pred     = nil

    # Free list
    @next_free = nil

    # Adjacency info
    @edges    = []

    # Landmark data
    @landmark = Array.new(NUM_LANDMARKS, INFINITY)

    # Connected component label
    @component = 0
  end

  # Sentinel node
  NIL = Vertex.new(INFINITY, INFINITY)
  NIL.weight = -INFINITY
  NIL.left = NIL.right = NIL.parent = NIL
end

# //Graph topology
# exports.create        = createVertex
# exports.link          = addEdge

# //Free list management
# exports.insert        = pushList
# exports.clear         = clearList

# //Heap operations
# exports.NIL           = NIL
# exports.push          = heapPush
# exports.pop           = takeMin
# exports.decreaseKey   = decreaseKey

# //Landmark info
# exports.NUM_LANDMARKS = NUM_LANDMARKS
# exports.LANDMARK_DIST = LANDMARK_DIST
