require 'lib/l1pf'

# Create a grid with walls (exact same as JS example)
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

# Create the planner
planner = Planner.create(grid)

# Find a path from (0, 0) to (7, 6)
# Demonstrates L1 (Manhattan) pathfinding around walls
start_x = 0
start_y = 0
end_x = 7
end_y = 6
path = []

# Search returns the distance and fills the path array
distance = planner.search(start_x, start_y, end_x, end_y, path)

if distance < Float::INFINITY
  puts "Path found! Distance: #{distance}"
  puts "Path coordinates: #{path.inspect}"
  # path is a flat array: [x0, y0, x1, y1, x2, y2, ...]
else
  puts "No path found!"
end
