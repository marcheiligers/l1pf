# Tests for L1PathPlanner

def test_planner_basic_path(_args, assert)
  # Create an empty 4x4 grid (no obstacles) for basic testing
  grid_data = Array.new(16, 0)
  grid = NDArray.new(grid_data, [4, 4])

  # Create planner
  planner = Planner.create(grid)
  assert.true!(planner.is_a?(Planner::L1PathPlanner), 'planner should be Planner::L1PathPlanner instance')

  # Test path from (0,0) to (2,3)
  # Note: despite parameter names, first pair is SOURCE, second pair is TARGET
  path = []
  dist = planner.search(0, 0, 2, 3, path)

  assert.true!(dist > 0 && dist < Float::INFINITY, "should find valid path (got dist=#{dist})")
  assert.true!(path.length > 0, 'path should not be empty')

  # L1 distance = |2-0| + |3-0| = 5
  assert.equal!(dist, 5, 'distance should be L1 distance')

  # Path should start at source
  assert.equal!(path[0], 0, 'path starts at source x')
  assert.equal!(path[1], 0, 'path starts at source y')

  # Path should end at target
  assert.equal!(path[path.length - 2], 2, 'path ends at target x')
  assert.equal!(path[path.length - 1], 3, 'path ends at target y')
end

def test_planner_blocked_path(_args, assert)
  # Create a grid with a wall separating start and goal
  grid_data = [
    0, 0, 0, 0,
    1, 1, 1, 1,
    0, 0, 0, 0,
    0, 0, 0, 0
  ]
  grid = NDArray.new(grid_data, [4, 4])

  planner = Planner.create(grid)

  # Try to path from (0,0) to (2,0) - blocked by wall
  path = []
  dist = planner.search(0, 0, 2, 0, path)

  assert.equal!(dist, Float::INFINITY, 'blocked path should have infinite distance')
  assert.equal!(path.length, 0, 'blocked path should be empty')
end

def test_planner_same_start_end(_args, assert)
  grid_data = Array.new(16, 0)
  grid = NDArray.new(grid_data, [4, 4])

  planner = Planner.create(grid)

  # Path from (1,1) to (1,1)
  path = []
  dist = planner.search(1, 1, 1, 1, path)

  assert.equal!(dist, 0, 'same start/end should have zero distance')
  assert.equal!(path.length, 2, 'same start/end path should contain one point')
  assert.equal!(path[0], 1, 'path x should be start point')
  assert.equal!(path[1], 1, 'path y should be start point')
end

def test_planner_direct_connection(_args, assert)
  grid_data = Array.new(16, 0)
  grid = NDArray.new(grid_data, [4, 4])

  planner = Planner.create(grid)

  # Path from (0,0) to (2,3) - direct L1 path
  path = []
  dist = planner.search(0, 0, 2, 3, path)

  # L1 distance = |2-0| + |3-0| = 5
  assert.equal!(dist, 5, 'direct path should have L1 distance')
  assert.true!(path.length >= 4, 'path should have at least 2 waypoints')
end
