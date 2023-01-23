# https://github.com/scijs/ndarray/blob/master/ndarray.js
# ndarray(data[, shape, stride, offset])

class NDArray
  include Serializable
  serializable_ignore []

  attr_reader :data, :shape, :stride, :offset, :dimension, :order

  def initialize(data, shape = nil, stride = nil, offset = nil)
    @data = data

    @shape = shape || [data.length]
    @dimension = @shape.length

    @stride = stride || begin
      sz = 1

      stride = Array.new(@dimension)
      (@dimension - 1).downto(0) do |i|
        stride[i] = sz
        sz *= @shape[i]
      end

      stride
    end

    @order = case @dimension
             when 0 then []
             when 1 then [0]
             when 2 then @stride[0].abs > @stride[1].abs ? [1, 0] : [0, 1]
             else @stride.zip(iota(@dimension)).sort_by { |a| -a[0].abs }.map { |a| a[1] }
             end

    @offset = offset || begin
      offset = 0

      @dimension.times do |i|
        offset -= (shape[i] - 1) * stride[i] if stride[i] < 0
      end

      offset
    end
  end

  def size
    @shape.reduce(1, :*)
  end

  def step(*pos)
    shp = @shape.dup
    str = @stride.dup
    ost = @offset

    @dimension.times do |i|
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
    @dimension.times do |i|
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

  def +(val)
    NDArray.new(
      @data.map { |n| n + val },
      @shape.dup,
      @stride.dup,
      @offset
    )
  end

  def to_a
    if @dimension == 0
      get
    elsif @dimension == 1
      @shape[0].times.map { |i| get(i) }
    else
      @shape[0].times.map { |i| pick(i).to_a }
    end
  end

  def index(*pos)
    s = @offset
    pos[0...@dimension].each.with_index { |p, i| s += @stride[i] * p }
    s
  end

  def hi(*pos)
    NDArray.new(
      @data,
      @dimension.times.map { |i| (pos[i].is_a?(Integer) && pos[i] >= 0) ? pos[i] : @shape[i] },
      @stride,
      @offset
    )
  end

  def lo(*pos)
    shp = @shape.dup
    ost = @offset
    d = 0

    @dimension.times do |i|
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

    @dimension.times do |i|
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

class NilDArray < NDArray
  include Serializable
  serializable_ignore []

  attr_reader :data, :shape, :stride, :offset, :dimension, :order

  def initialize(data, _shape = nil, _stride = nil, _offset = nil)
    super(data, [], [], nil)
    @data = data
    @offset = nil
    @dimension = -1
    @order = []
  end

  def get(*_pos)
    nil
  end
end
