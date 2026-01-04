# 'use strict'

# var ndarray     = require('ndarray')
# var uniq        = require('uniq')
# var ops         = require('ndarray-ops')
# var prefixSum   = require('ndarray-prefix-sum')
# var getContour  = require('contour-2d')
# var orient      = require('robust-orientation')[3]

# module.exports = createGeometry

# TODO: namespace pollution - class should be nested in a module (e.g., Geometry::PathGeometry)
class PathGeometry
  attr_reader :corners, :grid

  def initialize(corners, grid)
    @corners = corners
    @grid    = grid
  end

  def stabRay(vx, vy, x) # TODO: rename to stab_ray (snake_case convention)
    stabBox(vx, vy, x, vy)
  end

  def stabTile(x, y) # TODO: rename to stab_tile (snake_case convention)
    stabBox(x, y, x, y)
  end

  def integrate(x, y)
    return 0 if x < 0 || y < 0

    return @grid.get(
      # [x, @grid.shape[0]-1].min.to_i,
      # [y, @grid.shape[1]-1].min.to_i
      x.lesser(@grid.shape[0]-1),
      y.lesser(@grid.shape[1]-1)
    )
  end

  def stabBox(ax, ay, bx, by) # TODO: rename to stab_box (snake_case convention)
    # lox = [ax, bx].min
    # loy = [ay, by].min
    # hix = [ax, bx].max
    # hiy = [ay, by].max
    lox = ax.lesser(bx)
    loy = ay.lesser(by)
    hix = ax.greater(bx)
    hiy = ay.greater(by)

    s = integrate(lox - 1, loy - 1) - integrate(lox - 1, hiy) - integrate(hix, loy - 1) + integrate(hix, hiy)

    return s > 0
  end
end

# TODO: namespace pollution - wrap in module or make this a private helper
def comparePair(a, b) # TODO: rename to compare_pair (snake_case convention); is this basically saying return a == b?
  d = a[0] - b[0]
  return d unless d.zero?

  a[1] - b[1]
end

# TODO: namespace pollution - this is the main export, should be in a module (e.g., Geometry.create or Geometry::create_geometry)
def createGeometry(grid) # TODO: rename to create_geometry (snake_case convention)
  loops = getContours(grid.transpose(1,0), false)

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
      if orient(a, b, c) > 0
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
          offset[j] = b[j] + [sign, 0].min
        end
        if(offset[0] >= 0 && offset[0] < grid.shape[0] &&
           offset[1] >= 0 && offset[1] < grid.shape[1] &&
           grid.get(offset[0], offset[1]) == 0)
          corners.push(offset)
        end
      end
    end
  end

  # Remove duplicate corners
  corners = uniq(corners, method(:comparePair))

  # Create integral image
  img = NDArray.new(Array.new(grid.shape[0]*grid.shape[1], 0), grid.shape)
  ops_gts(img, grid, 0)
  prefix_sum(img)

  # Return resulting geometry
  PathGeometry.new(corners, img)
end
