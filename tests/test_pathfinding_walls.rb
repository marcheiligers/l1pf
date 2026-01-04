def test_pathfinding_js_example(_args, assert)
  # Exact same data from the JavaScript example
  grid_data = [
    0, 1, 0, 0, 0, 0, 0,
    0, 1, 0, 1, 0, 0, 0,
    0, 1, 0, 1, 1, 1, 0,
    0, 1, 0, 1, 0, 0, 0,
    0, 1, 0, 1, 0, 0, 0,
    0, 1, 0, 1, 0, 0, 0,
    0, 1, 0, 1, 0, 1, 1,
    0, 0, 0, 1, 0, 0, 0
  ]
  grid = NDArray.new(grid_data, [8, 7])

  planner = createPlanner(grid)
  path = []
  dist = planner.search(0, 0, 7, 6, path)

  assert.true!(dist < Float::INFINITY, "Should find a path like JS example (got dist=#{dist})")
  assert.true!(path.length > 0, "Path should not be empty")
end

def test_pathfinding_with_walls(_args, assert)
  # Create a 5x5 grid with walls
  grid_data = [
    0, 0, 0, 0, 0,
    0, 1, 0, 1, 0,
    0, 1, 0, 1, 0,
    0, 0, 0, 0, 0,
    0, 0, 0, 0, 0
  ]
  grid = NDArray.new(grid_data, [5, 5])

  planner = createPlanner(grid)
  path = []
  dist = planner.search(0, 0, 4, 4, path)

  assert.true!(dist < Float::INFINITY, "Should find a path with walls present (got dist=#{dist})")
  assert.true!(path.length > 0, "Path should not be empty")
end

def test_pathfinding_single_wall(_args, assert)
  # Create a 4x4 grid with a single wall
  grid_data = [
    0, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0
  ]
  grid = NDArray.new(grid_data, [4, 4])

  planner = createPlanner(grid)
  path = []
  dist = planner.search(0, 0, 3, 3, path)

  assert.true!(dist < Float::INFINITY, "Should find a path around single wall (got dist=#{dist})")
  assert.true!(path.length > 0, "Path should not be empty")
end

def test_pathfinding_c_shaped_wall(_args, assert)
  # Create a 7x7 grid with border and C-shaped obstacle
  grid_data = [
    1, 1, 1, 1, 1, 1, 1,
    1, 0, 0, 0, 0, 0, 1,
    1, 0, 1, 1, 1, 0, 1,
    1, 0, 1, 0, 0, 0, 1,
    1, 0, 1, 0, 0, 0, 1,
    1, 0, 0, 0, 0, 0, 1,
    1, 1, 1, 1, 1, 1, 1
  ]
  grid = NDArray.new(grid_data, [7, 7])

  planner = createPlanner(grid)
  path = []
  dist = planner.search(1, 1, 5, 5, path)

  assert.true!(dist < Float::INFINITY, "Should find a path in bordered grid (got dist=#{dist})")
  assert.true!(path.length > 0, "Path should not be empty")
end
