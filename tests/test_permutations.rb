def test_invert_permutation_0(_args, assert)
  assert.equal!(Permutations.invert([]), [])
end

def test_invert_permutation_1(_args, assert)
  assert.equal!(Permutations.invert([0]), [0])
end

def test_invert_permutation_2(_args, assert)
  assert.equal!(Permutations.invert([0, 1]), [0, 1])
  assert.equal!(Permutations.invert([1, 0]), [1, 0])
end

def test_invert_permutation_3(_args, assert)
  assert.equal!(Permutations.invert([0, 1, 2]), [0, 1, 2])
  assert.equal!(Permutations.invert([2, 1, 0]), [2, 1, 0])
  assert.equal!(Permutations.invert([1, 2, 0]), [2, 0, 1])
end

# > var ps = [[0, 1, 2], [0, 2, 1], [1, 0, 2], [1, 2, 0], [2, 0, 1], [2, 1, 0]]
# undefined
# > console.log(ps)
# [
#   [ 0, 1, 2 ],
#   [ 0, 2, 1 ],
#   [ 1, 0, 2 ],
#   [ 1, 2, 0 ],
#   [ 2, 0, 1 ],
#   [ 2, 1, 0 ]
# ]
# > var invPerm = require("invert-permutation")
# undefined
# > console.log(ps.map((p) => invPerm(p)))
# [
#   [ 0, 1, 2 ],
#   [ 0, 2, 1 ],
#   [ 1, 0, 2 ],
#   [ 2, 0, 1 ],
#   [ 1, 2, 0 ],
#   [ 2, 1, 0 ]
# ]
# undefined

INVERTS = [
  [ 0, 1, 2 ],
  [ 0, 2, 1 ],
  [ 1, 0, 2 ],
  [ 1, 2, 0 ],
  [ 2, 0, 1 ],
  [ 2, 1, 0 ]
].zip([
  [ 0, 1, 2 ],
  [ 0, 2, 1 ],
  [ 1, 0, 2 ],
  [ 2, 0, 1 ],
  [ 1, 2, 0 ],
  [ 2, 1, 0 ]
])

def test_invert_permutation_4(_args, assert)
  INVERTS.each do |from, to|
    assert.equal!(Permutations.invert(from), to)
  end
end


PERMUTATION_RANKS = [
  [1, 2, 3, 0],
  [2, 1, 3, 0],
  [2, 3, 1, 0],
  [3, 2, 1, 0],
  [1, 3, 2, 0],
  [3, 1, 2, 0],
  [3, 2, 0, 1],
  [2, 3, 0, 1],
  [2, 0, 3, 1],
  [0, 2, 3, 1],
  [3, 0, 2, 1],
  [0, 3, 2, 1],
  [1, 3, 0, 2],
  [3, 1, 0, 2],
  [3, 0, 1, 2],
  [0, 3, 1, 2],
  [1, 0, 3, 2],
  [0, 1, 3, 2],
  [1, 2, 0, 3],
  [2, 1, 0, 3],
  [2, 0, 1, 3],
  [0, 2, 1, 3],
  [1, 0, 2, 3],
  [0, 1, 2, 3]
]

def test_permutation_rank(_args, assert)
  assert.equal!(Permutations.rank([]), 0)
  assert.equal!(Permutations.rank([0]), 0)
  PERMUTATION_RANKS.length.times do |i|
    assert.equal!(Permutations.rank(PERMUTATION_RANKS[i]), i, "permutation_rank #{i}: #{PERMUTATION_RANKS[i]}")
  end
end

def check_permutation_unrank(assert, r, b)
  a = Permutations.unrank(b.length, r)
  assert.equal!(a, b, "permutation_unrank #{r}: #{b}")
end

def test_permutation_unrank(_args, assert)
  check_permutation_unrank(assert, 0, [])
  check_permutation_unrank(assert, 0, [0])
  check_permutation_unrank(assert, 0, [1, 0])
  check_permutation_unrank(assert, 1, [0, 1])

  PERMUTATION_RANKS.length.times do |i|
    check_permutation_unrank(assert, i, PERMUTATION_RANKS[i])
  end
end
