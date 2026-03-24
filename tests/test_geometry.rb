# Tests for Geometry::PathGeometry module

def test_geometry_simple_grid(_args, assert)
  # Create a simple 5x5 grid with an obstacle in the middle
  grid_data = [
    0, 0, 0, 0, 0,
    0, 0, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 0, 0, 0,
    0, 0, 0, 0, 0
  ]

  grid = NDArray.new(grid_data, [5, 5])

  # Create geometry
  geom = Geometry.create_geometry(grid)

  # Basic checks
  assert.true!(geom.is_a?(Geometry::PathGeometry), 'geometry should be Geometry::PathGeometry instance')
  assert.true!(geom.corners.is_a?(Array), 'corners should be an array')
  assert.true!(geom.grid.is_a?(L1Grid), 'grid should be an L1Grid')
end

def test_geometry_stab_box(_args, assert)
  # Create a simple grid
  grid_data = Array.new(25, 0)
  grid_data[12] = 1  # Center obstacle at (2,2)
  grid = NDArray.new(grid_data, [5, 5])

  geom = Geometry.create_geometry(grid)

  # Test stabBox - should detect obstacle at center
  assert.true!(geom.stab_box(2, 2, 2, 2), 'should detect obstacle at (2,2)')

  # Test area without obstacle
  assert.false!(geom.stab_box(0, 0, 1, 1), 'should not detect obstacle at (0,0) to (1,1)')
end

def test_geometry_empty_grid(_args, assert)
  # Empty grid should work without errors
  grid_data = Array.new(25, 0)
  grid = NDArray.new(grid_data, [5, 5])

  geom = Geometry.create_geometry(grid)

  assert.true!(geom.is_a?(Geometry::PathGeometry), 'geometry should be created for empty grid')
  assert.equal!(geom.corners.length, 0, 'empty grid should have no corners')
end
