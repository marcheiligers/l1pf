# Tests for uniq function
# Translated from: https://github.com/mikolalysenko/uniq/blob/master/test/test.js

def test_uniq(_args, assert)
  assert.equal!(uniq([1,1,2,3,5,5,7], nil).join(','), [1,2,3,5,7].join(','))
  assert.equal!(uniq([], nil).join(','), [].join(','))
  assert.equal!(uniq([1,1,1], nil).join(','), [1].join(','))

  cmp = ->(a, b) { (a ^ b) & 1 }
  assert.equal!(uniq([1,1,1,2,2,2], cmp).join(','), [2,1].join(','))
end
