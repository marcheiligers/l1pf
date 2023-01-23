# 'use strict'

# var ndarray     = require('ndarray')
# var uniq        = require('uniq')
# var ops         = require('ndarray-ops')
# var prefixSum   = require('ndarray-prefix-sum')
# var getContour  = require('contour-2d')
# var orient      = require('robust-orientation')[3]

# module.exports = createGeometry

class Geometry
  def initialize(corners, grid)
    @corners = corners
    @grid    = grid
  end

  def stabRay(vx, vy, x)
    stabBox(vx, vy, x, vy)
  end

  def stabTile(x, y)
    stabBox(x, y, x, y)
  end

  def integrate(x, y)
    return 0 if x < 0 || y < 0

    return grid.get(
      Math.min(x, @grid.shape[0]-1)|0,
      Math.min(y, @grid.shape[1]-1)|0
    )
  end

  def stabBox(ax, ay, bx, by)
    lox = Math.min(ax, bx)
    loy = Math.min(ay, by)
    hix = Math.max(ax, bx)
    hiy = Math.max(ay, by)

    s = integrate(lox - 1, loy - 1) - integrate(lox - 1, hiy) - integrate(hix, loy - 1) + integrate(hix, hiy)

    return s > 0
  end
end

def comparePair(a, b)
  d = a[0] - b[0]
  return d unless d.zero?

  a[1] - b[1]
end

def createGeometry(grid)
  loops = getContour(grid.transpose(1,0))

  # Extract corners
  corners = []
  loops.length.times do |k|
    polygon = loops[k]
    polygon.length.times do |i|
      a = polygon[(i+polygon.length-1)%polygon.length]
      b = polygon[i]
      c = polygon[(i+1)%polygon.length]
      if orient(a, b, c) > 0
        var offset = [0,0]
        2.times do |j|
          if(b[j] - a[j])
            offset[j] = b[j] - a[j]
          else
            offset[j] = b[j] - c[j]
          end
          offset[j] = b[j]+Math.min(Math.round(offset[j]/Math.abs(offset[j]))|0, 0)
        end
        if(offset[0] >= 0 && offset[0] < grid.shape[0] &&
           offset[1] >= 0 && offset[1] < grid.shape[1] &&
           grid.get(offset[0], offset[1]) === 0)
          corners.push(offset)
        end
      end
    end
  end

  # Remove duplicate corners
  uniq(corners, comparePair)

  # Create integral image
  var img = ndarray(new Int32Array(grid.shape[0]*grid.shape[1]), grid.shape)
  ops.gts(img, grid, 0)
  prefixSum(img)

  # Return resulting geometry
  Geometry.new(corners, img)
end
