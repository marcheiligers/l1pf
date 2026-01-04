# Binary search bounds functions
# Translated from: https://github.com/mikolalysenko/binary-search-bounds
#
# Parameters:
#   a - array to search
#   y - value to search for
#   c - comparator function (optional lambda/proc that takes (x, y) and returns x - y)
#   l - low index
#   h - high index

module BSearch
  extend self

  def ge(a, y, c = nil, l = nil, h = nil)
    l = 0 if l.nil?
    h = a.length - 1 if h.nil?
    i = h + 1

    while l <= h
      m = (l + h) >> 1
      x = a[m]
      p = c ? c.call(x, y) : (x - y)
      if p >= 0
        i = m
        h = m - 1
      else
        l = m + 1
      end
    end

    i
  end

  def gt(a, y, c = nil, l = nil, h = nil)
    l = 0 if l.nil?
    h = a.length - 1 if h.nil?
    i = h + 1

    while l <= h
      m = (l + h) >> 1
      x = a[m]
      p = c ? c.call(x, y) : (x - y)
      if p > 0
        i = m
        h = m - 1
      else
        l = m + 1
      end
    end

    i
  end

  def lt(a, y, c = nil, l = nil, h = nil)
    l = 0 if l.nil?
    h = a.length - 1 if h.nil?
    i = l - 1

    while l <= h
      m = (l + h) >> 1
      x = a[m]
      p = c ? c.call(x, y) : (x - y)
      if p < 0
        i = m
        l = m + 1
      else
        h = m - 1
      end
    end

    i
  end

  def le(a, y, c = nil, l = nil, h = nil)
    l = 0 if l.nil?
    h = a.length - 1 if h.nil?
    i = l - 1

    while l <= h
      m = (l + h) >> 1
      x = a[m]
      p = c ? c.call(x, y) : (x - y)
      if p <= 0
        i = m
        l = m + 1
      else
        h = m - 1
      end
    end

    i
  end

  def eq(a, y, c = nil, l = nil, h = nil)
    l = 0 if l.nil?
    h = a.length - 1 if h.nil?
    while l <= h
      m = (l + h) >> 1
      x = a[m]
      p = c ? c.call(x, y) : (x - y)
      return m if p == 0

      if p <= 0
        l = m + 1
      else
        h = m - 1
      end
    end

    -1
  end

  # def norm(a, y, c, l, h, f)
  #   if (typeof c === 'function') {
  #     return f(a, y, c, (l === undefined) ? 0 : l | 0, (h === undefined) ? a.length - 1 : h | 0);
  #   }
  #   return f(a, y, undefined, (c === undefined) ? 0 : c | 0, (l === undefined) ? a.length - 1 : l | 0);
  # end

  # module.exports = {
  #   ge: function(a, y, c, l, h) { return norm(a, y, c, l, h, ge)},
  #   gt: function(a, y, c, l, h) { return norm(a, y, c, l, h, gt)},
  #   lt: function(a, y, c, l, h) { return norm(a, y, c, l, h, lt)},
  #   le: function(a, y, c, l, h) { return norm(a, y, c, l, h, le)},
  #   eq: function(a, y, c, l, h) { return norm(a, y, c, l, h, eq)}
  # }
end

