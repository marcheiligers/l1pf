# Simple 2D grid optimized for L1PF pathfinding.
# Replaces TwoDArray/NDArray for the pathfinding hot paths
# with minimal overhead (no stride/offset indirection).

class L1Grid
  attr_reader :data, :rows, :cols, :stride0, :stride1, :offset

  def initialize(data, rows, cols = nil)
    if cols
      @rows = rows
      @cols = cols
    elsif rows.is_a?(Array)
      @rows = rows[0]
      @cols = rows[1]
    else
      raise "L1Grid requires rows and cols"
    end
    @data = data
    @stride0 = @cols
    @stride1 = 1
    @offset = 0
  end

  def get(x, y)
    @data[x * @cols + y]
  end

  def set(x, y, val)
    @data[x * @cols + y] = val
  end

  def shape
    [@rows, @cols]
  end

  def stride
    [@cols, 1]
  end

  def transpose(*_args)
    TransposedL1Grid.new(@data, @rows, @cols)
  end
end

# Lightweight transposed view — shares the same data array.
# Used by contour extraction which scans both orientations.
class TransposedL1Grid
  attr_reader :data, :rows, :cols, :stride0, :stride1, :offset

  def initialize(data, orig_rows, orig_cols)
    @data = data
    @rows = orig_cols
    @cols = orig_rows
    @orig_cols = orig_cols
    @stride0 = 1
    @stride1 = orig_cols
    @offset = 0
  end

  def get(x, y)
    @data[y * @orig_cols + x]
  end

  def shape
    [@rows, @cols]
  end

  def stride
    [1, @orig_cols]
  end

  def transpose(*_args)
    L1Grid.new(@data, @cols, @rows)
  end
end
