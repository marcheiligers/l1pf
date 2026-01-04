# https://github.com/scijs/ndarray/blob/master/ndarray.js
# ndarray(data[, shape, stride, offset])

class NDArray
  include Serializable
  serializable_ignore []

  attr_reader :data, :shape, :stride, :offset, :dimension

  # Factory method to return optimized array types
  def self.new(data, shape = nil, stride = nil, offset = nil)
    # Determine dimension
    if shape.nil?
      dim = 1
      shape = [data.length]
    else
      dim = shape.length
    end

    # Return optimized class for common cases
    case dim
    when 1
      OneDArray.allocate.tap { |obj| obj.send(:initialize, data, shape, stride, offset) }
    when 2
      TwoDArray.allocate.tap { |obj| obj.send(:initialize, data, shape, stride, offset) }
    else
      super
    end
  end

  def initialize(data, shape = nil, stride = nil, offset = nil)
    @data = data

    @shape = shape || [data.length]
    @dimension = @shape.length

    @stride = stride || begin
      sz = 1

      stride = Array.new(@dimension)
      i = @dimension
      while (i -= 1) >= 0
        stride[i] = sz
        sz *= @shape[i]
      end

      stride
    end

    @offset = offset || begin
      offset = 0

      i = -1
      while (i += 1) < @dimension
        offset -= (shape[i] - 1) * stride[i] if stride[i] < 0
      end

      offset
    end
  end

  def size
    @shape.reduce(1, :*)
  end

  def stride
    @stride ||= begin
      sz = 1

      str = Array.new(@dimension)
      i = @dimension
      while (i -= 1) >= 0
        str[i] = sz
        sz *= @shape[i]
      end

      str
    end
  end

  def order
    @order ||= case @dimension
               when 0 then []
               when 1 then [0]
               when 2 then @stride[0].abs > @stride[1].abs ? [1, 0] : [0, 1]
               else @stride.zip(iota(@dimension)).sort_by { |a| a[0].abs }.map { |a| a[1] }
               end
  end

  def step(*pos)
    shp = @shape.dup
    str = @stride.dup
    ost = @offset

    i = -1
    while (i += 1) < @dimension
      if pos[i].is_a?(Integer)
        d = pos[i]
        if d < 0
          ost += str[i] * (shp[i] - 1)
          shp[i] = (-shp[i] / d).ceil
        else
          shp[i] = (shp[i] / d).ceil
        end
        str[i] *= d
      end
    end

    NDArray.new(@data, shp, str, ost)
  end

  def transpose(*pos)
    shp = []
    str = []
    i = -1
    while (i += 1) < @dimension
      d = pos[i].is_a?(Integer) ? pos[i] : i
      shp[i] = @shape[d]
      str[i] = @stride[d]
    end

    NDArray.new(@data, shp, str, @offset)
  end

  def ==(other)
    case other
    when NDArray
      @data == other.data && @shape == other.shape && @stride == other.stride && @offset == other.offset
    else
      to_a == other
    end
  end

  def +(other)
    NDArray.new(
      @data.map { |n| n + other },
      @shape.dup,
      @stride.dup,
      @offset
    )
  end

  def to_a
    if @dimension == 0
      get
    elsif @dimension == 1
      result = []
      i = -1
      while (i += 1) < @shape[0]
        result.push(get(i))
      end
      result
    else
      result = []
      i = -1
      while (i += 1) < @shape[0]
        result.push(pick(i).to_a)
      end
      result
    end
  end

  def index(*pos)
    # Fast path for 2D arrays (most common case)
    if @dimension == 2
      return @offset + @stride[0] * pos[0] + @stride[1] * pos[1]
    end

    # Generic path for other dimensions
    s = @offset
    stride = @stride
    dim = @dimension
    i = -1
    while (i += 1) < dim
      s += stride[i] * pos[i]
    end
    s
  end

  def hi(*pos)
    shp = []
    i = -1
    while (i += 1) < @dimension
      shp.push((pos[i].is_a?(Integer) && pos[i] >= 0) ? pos[i] : @shape[i])
    end

    NDArray.new(
      @data,
      shp,
      @stride,
      @offset
    )
  end

  def lo(*pos)
    shp = @shape.dup
    ost = @offset
    d = 0

    i = -1
    while (i += 1) < @dimension
      if pos[i].is_a?(Integer) && pos[i] >= 0
        d = pos[i]
        ost += @stride[i] * d
        shp[i] -= d
      end
    end

    NDArray.new(@data, shp, @stride.dup, ost)
  end

  def pick(*pos)
    return NilDArray.new(@data) if @dimension == 0

    shp = []
    str = []
    ost = @offset

    i = -1
    while (i += 1) < @dimension
      if pos[i].is_a?(Integer) && pos[i] >= 0
        ost = (ost + @stride[i] * pos[i])
      else
        shp.push(@shape[i])
        str.push(@stride[i])
      end
    end

    NDArray.new(@data, shp, str, ost)
  end

  def get(*pos)
    # Fast path for 2D arrays (most common case) - avoid method call overhead
    if @dimension == 2
      return @data[@offset + @stride[0] * pos[0] + @stride[1] * pos[1]]
    end

    @data[index(*pos)]
  end

  # TODO: figure out if this is what we really want
  def [](*pos)
    @data[index(*pos)]
  end

  def set(*pos, val)
    @data[index(*pos)] = val
  end

  def []=(*pos, val)
    @data[index(*pos)] = val
  end
end

# Optimized 1D array - eliminates dimension checks and loops
class OneDArray < NDArray
  include Serializable
  serializable_ignore []

  attr_reader :data, :shape, :stride, :offset, :dimension

  # Override new to bypass NDArray factory
  def self.new(data, shape = nil, stride = nil, offset = nil)
    allocate.tap { |obj| obj.send(:initialize, data, shape, stride, offset) }
  end

  def initialize(data, shape = nil, stride = nil, offset = nil)
    @data = data
    @dimension = 1

    if shape.nil?
      @shape = [data.length]
      @stride = [1]
      @offset = 0
    else
      @shape = shape
      @stride = stride || [1]
      @offset = offset || 0
    end
  end

  def size
    @shape[0]
  end

  def order
    @order ||= [0]
  end

  def index(*pos)
    @offset + @stride[0] * pos[0]
  end

  def get(*pos)
    @data[@offset + @stride[0] * pos[0]]
  end

  def [](*pos)
    @data[@offset + @stride[0] * pos[0]]
  end

  def set(*args)
    val = args.pop
    @data[@offset + @stride[0] * args[0]] = val
  end

  def []=(*args)
    val = args.pop
    @data[@offset + @stride[0] * args[0]] = val
  end

  def step(s)
    shp = @shape.dup
    str = @stride.dup
    ost = @offset

    if s < 0
      ost += str[0] * (shp[0] - 1)
      shp[0] = (-shp[0] / s).ceil
    else
      shp[0] = (shp[0] / s).ceil
    end
    str[0] *= s

    OneDArray.new(@data, shp, str, ost)
  end

  def transpose(*_pos)
    OneDArray.new(@data, @shape.dup, @stride.dup, @offset)
  end

  def ==(other)
    case other
    when OneDArray
      @data == other.data && @shape == other.shape && @stride == other.stride && @offset == other.offset
    else
      to_a == other
    end
  end

  def to_a
    result = []
    i = -1
    while (i += 1) < @shape[0]
      result.push(get(i))
    end
    result
  end

  def hi(x = nil)
    shp = [(x.is_a?(Integer) && x >= 0) ? x : @shape[0]]
    OneDArray.new(@data, shp, @stride, @offset)
  end

  def lo(x = nil)
    if x.is_a?(Integer) && x >= 0
      shp = [@shape[0] - x]
      ost = @offset + @stride[0] * x
      OneDArray.new(@data, shp, @stride.dup, ost)
    else
      OneDArray.new(@data, @shape.dup, @stride.dup, @offset)
    end
  end

  def pick(x)
    if x.is_a?(Integer) && x >= 0
      NilDArray.new(@data, @offset + @stride[0] * x)
    else
      OneDArray.new(@data, @shape.dup, @stride.dup, @offset)
    end
  end
end

# Optimized 2D array - eliminates dimension checks and loops
class TwoDArray < NDArray
  include Serializable
  serializable_ignore []

  attr_reader :data, :shape, :stride, :offset, :dimension

  # Override new to bypass NDArray factory
  def self.new(data, shape, stride = nil, offset = nil)
    allocate.tap { |obj| obj.send(:initialize, data, shape, stride, offset) }
  end

  def initialize(data, shape, stride = nil, offset = nil)
    @data = data
    @dimension = 2
    @shape = shape

    if stride.nil?
      @stride = [shape[1], 1]
      @offset = 0
    else
      @stride = stride
      @offset = offset || 0
    end
  end

  def size
    @shape[0] * @shape[1]
  end

  def order
    @order ||= @stride[0].abs > @stride[1].abs ? [1, 0] : [0, 1]
  end

  def index(*pos)
    @offset + @stride[0] * pos[0] + @stride[1] * pos[1]
  end

  def get(*pos)
    @data[@offset + @stride[0] * pos[0] + @stride[1] * pos[1]]
  end

  def [](*pos)
    @data[@offset + @stride[0] * pos[0] + @stride[1] * pos[1]]
  end

  def set(*args)
    val = args.pop
    @data[@offset + @stride[0] * args[0] + @stride[1] * args[1]] = val
  end

  def []=(*args)
    val = args.pop
    @data[@offset + @stride[0] * args[0] + @stride[1] * args[1]] = val
  end

  def step(sx, sy = nil)
    shp = @shape.dup
    str = @stride.dup
    ost = @offset

    if sx.is_a?(Integer)
      if sx < 0
        ost += str[0] * (shp[0] - 1)
        shp[0] = (-shp[0] / sx).ceil
      else
        shp[0] = (shp[0] / sx).ceil
      end
      str[0] *= sx
    end

    if sy.is_a?(Integer)
      if sy < 0
        ost += str[1] * (shp[1] - 1)
        shp[1] = (-shp[1] / sy).ceil
      else
        shp[1] = (shp[1] / sy).ceil
      end
      str[1] *= sy
    end

    TwoDArray.new(@data, shp, str, ost)
  end

  def transpose(i = nil, j = nil)
    i = i.is_a?(Integer) ? i : 0
    j = j.is_a?(Integer) ? j : 1

    shp = [@shape[i], @shape[j]]
    str = [@stride[i], @stride[j]]

    TwoDArray.new(@data, shp, str, @offset)
  end

  def ==(other)
    case other
    when TwoDArray
      @data == other.data && @shape == other.shape && @stride == other.stride && @offset == other.offset
    else
      to_a == other
    end
  end

  def to_a
    result = []
    i = -1
    while (i += 1) < @shape[0]
      row = []
      j = -1
      while (j += 1) < @shape[1]
        row.push(get(i, j))
      end
      result.push(row)
    end
    result
  end

  def hi(x = nil, y = nil)
    shp = [
      (x.is_a?(Integer) && x >= 0) ? x : @shape[0],
      (y.is_a?(Integer) && y >= 0) ? y : @shape[1]
    ]
    TwoDArray.new(@data, shp, @stride, @offset)
  end

  def lo(x = nil, y = nil)
    shp = @shape.dup
    ost = @offset

    if x.is_a?(Integer) && x >= 0
      ost += @stride[0] * x
      shp[0] -= x
    end

    if y.is_a?(Integer) && y >= 0
      ost += @stride[1] * y
      shp[1] -= y
    end

    TwoDArray.new(@data, shp, @stride.dup, ost)
  end

  def pick(x, y = nil)
    if x.is_a?(Integer) && x >= 0
      if y.is_a?(Integer) && y >= 0
        # Both dimensions picked - return 0D
        NilDArray.new(@data, @offset + @stride[0] * x + @stride[1] * y)
      else
        # First dimension picked - return 1D
        shp = [@shape[1]]
        str = [@stride[1]]
        ost = @offset + @stride[0] * x
        OneDArray.new(@data, shp, str, ost)
      end
    elsif y.is_a?(Integer) && y >= 0
      # Second dimension picked - return 1D
      shp = [@shape[0]]
      str = [@stride[0]]
      ost = @offset + @stride[1] * y
      OneDArray.new(@data, shp, str, ost)
    else
      # Nothing picked - return 2D
      TwoDArray.new(@data, @shape.dup, @stride.dup, @offset)
    end
  end
end

class NilDArray < NDArray
  include Serializable
  serializable_ignore []

  attr_reader :data, :shape, :stride, :offset, :dimension, :order

  # Override new to bypass NDArray factory
  def self.new(data, offset = nil)
    allocate.tap { |obj| obj.send(:initialize, data, offset) }
  end

  def initialize(data, offset = nil)
    # Don't call super - set everything directly to avoid factory
    @data = data
    @shape = []
    @stride = []
    @offset = offset
    @dimension = -1
    @order = []
  end

  def get(*_pos)
    @offset.nil? ? nil : @data[@offset]
  end

  def index(*_pos)
    @offset
  end

  def set(val)
    return nil if @offset.nil?
    @data[@offset] = val
  end

  def size
    1
  end

  def +(other)
    @offset.nil? ? nil : @data[@offset] + other
  end

  def lo(*_pos)
    self
  end

  def pick(*_pos)
    self
  end
end
