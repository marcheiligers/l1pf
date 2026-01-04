# Computes the prefix sum (cumulative sum) of an ndarray
#
# For 2D arrays, this creates a "summed area table" or "integral image"
# which allows fast O(1) queries of rectangular sums.
#
# Formula for 2D:
#   result[i][j] = array[i][j] +
#                  result[i-1][j] +
#                  result[i][j-1] -
#                  result[i-1][j-1]
#
# Modifies the array in place and returns it.

def prefix_sum(array)
  shape = array.shape

  if shape.length == 1
    # 1D prefix sum
    n = shape[0]
    (1...n).each do |i|
      array.set(i, array.get(i) + array.get(i - 1))
    end
  elsif shape.length == 2
    # 2D prefix sum (integral image)
    rows = shape[0]
    cols = shape[1]

    # First pass: compute row-wise prefix sums
    rows.times do |i|
      (1...cols).each do |j|
        val = array.get(i, j) + array.get(i, j - 1)
        array.set(i, j, val)
      end
    end

    # Second pass: compute column-wise prefix sums
    cols.times do |j|
      (1...rows).each do |i|
        val = array.get(i, j) + array.get(i - 1, j)
        array.set(i, j, val)
      end
    end
  else
    raise "prefix_sum only supports 1D and 2D arrays, got #{shape.length}D"
  end

  array
end
