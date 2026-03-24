# 'use strict'

# var ndarray     = require('ndarray')
# var uniq        = require('uniq')
# var ops         = require('ndarray-ops')
# var prefixSum   = require('ndarray-prefix-sum')
# var getContour  = require('contour-2d')
# var orient      = require('robust-orientation')[3]

# module.exports = createGeometry

module Geometry
  class PathGeometry
  attr_reader :corners, :grid, :grid_data, :grid_cols, :max_x, :max_y

  def initialize(corners, grid)
    @corners = corners
    @grid    = grid
    @grid_data = grid.data
    @grid_cols = grid.cols
    @max_x   = grid.rows - 1
    @max_y   = grid.cols - 1
  end

  def stab_ray(vx, vy, x)
    stab_box(vx, vy, x, vy)
  end

  def stab_tile(x, y)
    stab_box(x, y, x, y)
  end

  def stab_box(ax, ay, bx, by)
    lox = ax < bx ? ax : bx
    loy = ay < by ? ay : by
    hix = ax > bx ? ax : bx
    hiy = ay > by ? ay : by

    max_x = @max_x
    max_y = @max_y
    data = @grid_data
    stride0 = @grid_cols

    lox1 = lox - 1
    loy1 = loy - 1

    # Inline integrate + grid.get to avoid method calls
    # grid.get(x, y) => data[x * stride0 + y] (stride[1] is always 1)
    v1 = (lox1 < 0 || loy1 < 0) ? 0 : data[(lox1 < max_x ? lox1 : max_x) * stride0 + (loy1 < max_y ? loy1 : max_y)]
    v2 = (lox1 < 0 || hiy < 0) ? 0 : data[(lox1 < max_x ? lox1 : max_x) * stride0 + (hiy < max_y ? hiy : max_y)]
    v3 = (hix < 0 || loy1 < 0) ? 0 : data[(hix < max_x ? hix : max_x) * stride0 + (loy1 < max_y ? loy1 : max_y)]
    v4 = (hix < 0 || hiy < 0) ? 0 : data[(hix < max_x ? hix : max_x) * stride0 + (hiy < max_y ? hiy : max_y)]

    v1 - v2 - v3 + v4 > 0
  end
  end

  # Helper function for comparing pairs
  def self.compare_pair(a, b)
    d = a[0] - b[0]
    return d unless d.zero?

    a[1] - b[1]
  end

  def self.create_geometry(grid)
  loops = Contour2D.get_contours(grid.transpose(1,0), false)

  # Extract corners
  corners = []
  l = loops.length
  k = -1
  while (k += 1) < l
    polygon = loops[k]
    pl = polygon.length
    i = -1
    while (i += 1) < pl
      a = polygon[(i+pl-1)%pl]
      b = polygon[i]
      c = polygon[(i+1)%pl]
      if Geometry.orient(a, b, c) > 0
        offset = [0,0]
        j = -1
        while (j += 1) < 2
          # Calculate direction from adjacent vertices
          if b[j] - a[j] != 0
            offset[j] = b[j] - a[j]
          else
            offset[j] = b[j] - c[j]
          end
          # Compute b[j] + min(sign(offset[j]), 0)
          # This gives b[j] if offset is positive, b[j]-1 if negative
          sign = offset[j] < 0 ? -1 : 1
          offset[j] = b[j] + (sign < 0 ? sign : 0)
        end
        if(offset[0] >= 0 && offset[0] < grid.rows &&
           offset[1] >= 0 && offset[1] < grid.cols &&
           grid.get(offset[0], offset[1]) == 0)
          corners.push(offset)
        end
      end
    end
  end

  # Remove duplicate corners
  # corners = uniq(corners, method(:comparePair))
  corners.uniq!

  # Create integral image using L1Grid
  grid_rows = grid.rows
  grid_cols = grid.cols
  grid_data = grid.data
  size = grid_rows * grid_cols
  img_data = Array.new(size, 0)

  # Binarize: img[i] = grid[i] > 0 ? 1 : 0
  i = -1
  while (i += 1) < size
    img_data[i] = grid_data[i] > 0 ? 1 : 0
  end

  # Prefix sum (integral image) - row-wise then column-wise
  i = -1
  while (i += 1) < grid_rows
    base = i * grid_cols
    j = 0
    while (j += 1) < grid_cols
      img_data[base + j] += img_data[base + j - 1]
    end
  end

  j = -1
  while (j += 1) < grid_cols
    i = 0
    while (i += 1) < grid_rows
      img_data[i * grid_cols + j] += img_data[(i - 1) * grid_cols + j]
    end
  end

  img = L1Grid.new(img_data, grid_rows, grid_cols)

  # Return resulting geometry
  PathGeometry.new(corners, img)
  end
end
