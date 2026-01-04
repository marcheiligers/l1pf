# Computes the orientation of a triple of points in the plane
# Translated from: https://github.com/mikolalysenko/robust-orientation
#
# Returns:
#   < 0 if the points are oriented counter-clockwise (left turn)
#   = 0 if the points are collinear
#   > 0 if the points are oriented clockwise (right turn)
#
# Formula from robust-orientation orientation3:
#   (a[1] - c[1]) * (b[0] - c[0]) - (a[0] - c[0]) * (b[1] - c[1])
#
# TODO: namespace pollution - wrap in a module (e.g., Geometry.orient or RobustOrientation.orient)
def orient(a, b, c)
  l = (a[1] - c[1]) * (b[0] - c[0])
  r = (a[0] - c[0]) * (b[1] - c[1])
  l - r
end
