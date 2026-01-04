# Tests for BSearch module
# Translated from: https://github.com/mikolalysenko/binary-search-bounds/blob/master/test/test.js

def test_binary_search_ge(_args, assert)
  # greaterThanEquals

  def check_array(arr, values, assert)
    arr.length.times do |l|
      (l...arr.length).each do |h|
        values.length.times do |i|
          j = l
          (l..h).each do |jj|
            j = jj
            break if arr[j] >= values[i]
          end
          j = h + 1 if j == h && arr[h] < values[i]

          result = BSearch.ge(arr, values[i], nil, l, h)
          assert.equal!(result, j, "search in [#{l},#{h}] for #{values[i]}")
        end
      end
    end
  end

  check_array([0,1,1,1,2], [-1, 0, 1, 2, 0.5, 1.5, 5], assert)

  assert.equal!(BSearch.ge([0,2,5,6], 0, nil, 0, 3), 0)
  assert.equal!(BSearch.ge([0,2,5,6], 1, nil, 0, 3), 1)
  assert.equal!(BSearch.ge([0,2,5,6], 2, nil, 0, 3), 1)
  assert.equal!(BSearch.ge([0,2,5,6], 3, nil, 0, 3), 2)
  assert.equal!(BSearch.ge([0,2,5,6], 4, nil, 0, 3), 2)
  assert.equal!(BSearch.ge([0,2,5,6], 5, nil, 0, 3), 2)
  assert.equal!(BSearch.ge([0,2,5,6], 6, nil, 0, 3), 3)

  cmp = ->(a, b) { a - b }

  assert.equal!(BSearch.ge([0,1,1,1,2], -1, cmp, 0, 4), 0)
  assert.equal!(BSearch.ge([0,1,1,1,2], 0, cmp, 0, 4), 0)
  assert.equal!(BSearch.ge([0,1,1,1,2], 1, cmp, 0, 4), 1)
  assert.equal!(BSearch.ge([0,1,1,1,2], 2, cmp, 0, 4), 4)
  assert.equal!(BSearch.ge([0,1,1,1,2], 0.5, cmp, 0, 4), 1)
  assert.equal!(BSearch.ge([0,1,1,1,2], 1.5, cmp, 0, 4), 4)
  assert.equal!(BSearch.ge([0,1,1,1,2], 5, cmp, 0, 4), 5)

  assert.equal!(BSearch.ge([0,2,5,6], 0, cmp, 0, 3), 0)
  assert.equal!(BSearch.ge([0,2,5,6], 1, cmp, 0, 3), 1)
  assert.equal!(BSearch.ge([0,2,5,6], 2, cmp, 0, 3), 1)
  assert.equal!(BSearch.ge([0,2,5,6], 3, cmp, 0, 3), 2)
  assert.equal!(BSearch.ge([0,2,5,6], 4, cmp, 0, 3), 2)
  assert.equal!(BSearch.ge([0,2,5,6], 5, cmp, 0, 3), 2)
  assert.equal!(BSearch.ge([0,2,5,6], 6, cmp, 0, 3), 3)
end

def test_binary_search_lt(_args, assert)
  # lessThan

  def check_array(arr, values, assert)
    arr.length.times do |l|
      (l...arr.length).each do |h|
        values.length.times do |i|
          j = h
          h.downto(l) do |jj|
            j = jj
            break if values[i] > arr[j]
          end
          j = l - 1 if j == l && values[i] <= arr[l]

          result = BSearch.lt(arr, values[i], nil, l, h)
          assert.equal!(result, j, "#{i} - indexOf(#{values[i]})=#{j} [#{l},#{h}]")
        end
      end
    end
  end

  check_array([0,1,1,1,2], [-1, 0, 1, 2, 0.5, 1.5, 5], assert)
end

def test_binary_search_gt(_args, assert)
  # greaterThan

  def check_array(arr, values, assert)
    arr.length.times do |l|
      (l...arr.length).each do |h|
        values.length.times do |i|
          j = l
          (l..h).each do |jj|
            j = jj
            break if arr[j] > values[i]
          end
          j = h + 1 if j == h && arr[h] <= values[i]

          result = BSearch.gt(arr, values[i], nil, l, h)
          assert.equal!(result, j)
        end
      end
    end
  end

  check_array([0,1,1,1,2], [-1, 0, 1, 2, 0.5, 1.5, 5], assert)
end

def test_binary_search_le(_args, assert)
  # lessThanEquals

  def check_array(arr, values, assert)
    values.length.times do |i|
      j = arr.length - 1
      (arr.length - 1).downto(0) do |jj|
        j = jj
        break if values[i] >= arr[j]
      end
      j = -1 if j == 0 && values[i] < arr[0]

      result = BSearch.le(arr, values[i], nil, 0, arr.length - 1)
      assert.equal!(result, j, "#{i} - indexOf(#{values[i]})=#{j}")
    end
  end

  check_array([0,1,1,1,2], [-1, 0, 1, 2, 0.5, 1.5, 5], assert)
end

def test_binary_search_eq(_args, assert)
  # equals

  def check_array(arr, values, assert)
    values.length.times do |i|
      idx = arr.index(values[i])
      result = BSearch.eq(arr, values[i], nil, 0, arr.length - 1)

      if idx.nil?
        assert.equal!(result, -1)
      else
        assert.equal!(arr[result], values[i])
      end
    end
  end

  check_array([0,1,1,1,2], [-1, 0, 1, 2, 0.5, 1.5, 5], assert)
end
