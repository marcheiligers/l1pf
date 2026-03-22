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

module NDArrayOps
  def self.prefix_sum(array)
  shape = array.shape

  if shape.length == 1
    # 1D prefix sum
    n = shape[0]
    i = 0
    while (i += 1) < n
      array.set(i, array.get(i) + array.get(i - 1))
    end
  elsif shape.length == 2
    # 2D prefix sum (integral image)
    rows = shape[0]
    cols = shape[1]
    data = array.data
    stride0 = array.stride[0]

    # First pass: compute row-wise prefix sums
    i = -1
    while (i += 1) < rows
      base = i * stride0
      j = 0
      while (j += 1) < cols
        data[base + j] += data[base + j - 1]
      end
    end

    # Second pass: compute column-wise prefix sums
    j = -1
    while (j += 1) < cols
      i = 0
      while (i += 1) < rows
        data[i * stride0 + j] += data[(i - 1) * stride0 + j]
      end
    end
  else
    raise "prefix_sum only supports 1D and 2D arrays, got #{shape.length}D"
  end

  array
  end
end
