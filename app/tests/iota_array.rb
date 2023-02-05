def test_iota(_args, assert)
  assert.equal!(iota(1), [0], 'Bad array from iota')
  assert.equal!(iota(2), [0, 1], 'Bad array from iota')
  assert.equal!(iota(3), [0, 1, 2], 'Bad array from iota')
  assert.equal!(iota(4), [0, 1, 2, 3], 'Bad array from iota')
end
