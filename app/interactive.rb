require 'lib/serializable'
require 'lib/permutations'
require 'lib/iota_array'
require 'lib/nd_array'
require 'lib/contour_2d'
require 'lib/binary_search_bounds'

# New utility functions
require 'lib/orient'
require 'lib/uniq'
require 'lib/nd_array_ops'
require 'lib/prefix_sum'

require 'lib/vertex'
require 'lib/graph'
require 'lib/geometry'
require 'lib/planner'

# Interactive L1 Pathfinding Demo

# GRID_SIZE = 15
# CELL_SIZE = 40

GRID_SIZE = 33
CELL_SIZE = 20

# GRID_SIZE = 65
# CELL_SIZE = 10

# GRID_SIZE = 129
# CELL_SIZE = 5

# GRID_SIZE = 255
# CELL_SIZE = 2

GRID_OFFSET_X = 40
GRID_OFFSET_Y = 40

def tick(args)
  args.state.grid_size ||= GRID_SIZE

  # Initialize on first tick
  if args.state.tick_count == 0
    init_demo(args)
  end

  # Handle input
  handle_input(args)

  # Update pathfinding
  update_path(args)

  # Render
  render(args)

  args.outputs.primitives << GTK.framerate_diagnostics_primitives
end

def init_demo(args)
  # Create grid with maze
  args.state.grid_data = generate_maze(GRID_SIZE, GRID_SIZE)
  args.state.grid = NDArray.new(args.state.grid_data, [GRID_SIZE, GRID_SIZE])

  # Set start and end points (must be odd coordinates for maze connectivity)
  args.state.start_x = 1
  args.state.start_y = 1
  # Use GRID_SIZE - 3 to ensure odd coordinate (since GRID_SIZE is typically even)
  args.state.end_x = GRID_SIZE.even? ? GRID_SIZE - 3 : GRID_SIZE - 2
  args.state.end_y = GRID_SIZE.even? ? GRID_SIZE - 3 : GRID_SIZE - 2

  # Clear start and end positions
  args.state.grid_data[args.state.start_y * GRID_SIZE + args.state.start_x] = 0
  args.state.grid_data[args.state.end_y * GRID_SIZE + args.state.end_x] = 0

  # Create planner
  args.state.planner = createPlanner(args.state.grid)

  # State for dragging
  args.state.dragging = nil # :start or :end
  args.state.path = []
  args.state.path_dist = Float::INFINITY
  args.state.needs_planner_update = false
end

def carve_path(grid, width, height, x, y, visited)
  # Mark as visited and carve
  visited[y * width + x] = true
  grid[y * width + x] = 0

  # Define possible directions (up, right, down, left)
  directions = [[0, -1], [1, 0], [0, 1], [-1, 0]]

  # Shuffle directions for randomness
  directions.shuffle!

  directions.each do |dx, dy|
    # Calculate neighbor position (2 steps away to account for walls)
    nx = x + dx * 2
    ny = y + dy * 2

    # Check if neighbor is valid and unvisited
    if nx > 0 && nx < width - 1 && ny > 0 && ny < height - 1 && !visited[ny * width + nx]
      # Carve the wall between current and neighbor
      wall_x = x + dx
      wall_y = y + dy
      grid[wall_y * width + wall_x] = 0

      # Recursively carve from neighbor
      carve_path(grid, width, height, nx, ny, visited)
    end
  end
end

def generate_maze(width, height)
  # Start with all walls
  grid = Array.new(width * height, 1)
  visited = Array.new(width * height, false)

  # Generate maze using recursive backtracking from (1,1)
  # This ensures all cells are connected
  carve_path(grid, width, height, 1, 1, visited)

  grid
end

def handle_input(args)
  mouse_x = args.inputs.mouse.x
  mouse_y = args.inputs.mouse.y

  # Convert screen coordinates to grid coordinates
  grid_x = ((mouse_x - GRID_OFFSET_X) / CELL_SIZE).to_i
  grid_y = ((mouse_y - GRID_OFFSET_Y) / CELL_SIZE).to_i

  # Check if mouse is in grid bounds
  in_bounds = grid_x >= 0 && grid_x < GRID_SIZE && grid_y >= 0 && grid_y < GRID_SIZE

  # Mouse down - start dragging or toggle wall
  if args.inputs.mouse.down && in_bounds
    if grid_x == args.state.start_x && grid_y == args.state.start_y
      args.state.dragging = :start
    elsif grid_x == args.state.end_x && grid_y == args.state.end_y
      args.state.dragging = :end
    else
      # Toggle wall (but not on start/end positions)
      unless (grid_x == args.state.start_x && grid_y == args.state.start_y) ||
             (grid_x == args.state.end_x && grid_y == args.state.end_y)
        idx = grid_y * GRID_SIZE + grid_x
        args.state.grid_data[idx] = args.state.grid_data[idx] == 0 ? 1 : 0

        # Ensure start/end are clear before recreating planner
        start_idx = args.state.start_y * GRID_SIZE + args.state.start_x
        end_idx = args.state.end_y * GRID_SIZE + args.state.end_x
        args.state.grid_data[start_idx] = 0
        args.state.grid_data[end_idx] = 0

        args.state.grid = NDArray.new(args.state.grid_data, [GRID_SIZE, GRID_SIZE])
        args.state.planner = createPlanner(args.state.grid)
      end
    end
  end

  # Mouse held - drag start or end point
  if args.inputs.mouse.button_left && in_bounds && args.state.dragging
    # Don't allow dragging onto walls
    idx = grid_y * GRID_SIZE + grid_x
    if args.state.grid_data[idx] == 0
      old_start_x = args.state.start_x
      old_start_y = args.state.start_y
      old_end_x = args.state.end_x
      old_end_y = args.state.end_y

      if args.state.dragging == :start
        args.state.start_x = grid_x
        args.state.start_y = grid_y
      elsif args.state.dragging == :end
        args.state.end_x = grid_x
        args.state.end_y = grid_y
      end

      # If position actually changed, update the grid
      if old_start_x != args.state.start_x || old_start_y != args.state.start_y ||
         old_end_x != args.state.end_x || old_end_y != args.state.end_y
        args.state.needs_planner_update = true
      end
    end
  end

  # Mouse up - stop dragging
  if args.inputs.mouse.up
    args.state.dragging = nil
  end

  # Press 'R' to regenerate maze
  if args.inputs.keyboard.key_down.r
    init_demo(args)
  end

  # Press 'C' to clear grid
  if args.inputs.keyboard.key_down.c
    args.state.grid_data = Array.new(GRID_SIZE * GRID_SIZE, 0)
    # Add border
    GRID_SIZE.times do |i|
      args.state.grid_data[i] = 1  # Top
      args.state.grid_data[(GRID_SIZE-1) * GRID_SIZE + i] = 1  # Bottom
      args.state.grid_data[i * GRID_SIZE] = 1  # Left
      args.state.grid_data[i * GRID_SIZE + GRID_SIZE - 1] = 1  # Right
    end

    # Ensure start/end are clear
    start_idx = args.state.start_y * GRID_SIZE + args.state.start_x
    end_idx = args.state.end_y * GRID_SIZE + args.state.end_x
    args.state.grid_data[start_idx] = 0
    args.state.grid_data[end_idx] = 0

    args.state.grid = NDArray.new(args.state.grid_data, [GRID_SIZE, GRID_SIZE])
    args.state.planner = createPlanner(args.state.grid)
  end
end

def update_path(args)
  # Recreate planner if needed (when start/end move or grid changes)
  # if args.state.needs_planner_update
    # Ensure start and end positions are clear in grid
    start_idx = args.state.start_y * GRID_SIZE + args.state.start_x
    end_idx = args.state.end_y * GRID_SIZE + args.state.end_x
    args.state.grid_data[start_idx] = 0
    args.state.grid_data[end_idx] = 0

    # Recreate grid and planner
    args.state.grid = NDArray.new(args.state.grid_data, [GRID_SIZE, GRID_SIZE])
    args.state.planner = createPlanner(args.state.grid)
    args.state.needs_planner_update = false
  # end

  # Run pathfinding
  if args.state.planner.nil?
    puts "WARNING: planner is nil, cannot search"
    args.state.path = []
    args.state.path_dist = Float::INFINITY
    return
  end

  path = []
  dist = args.state.planner.search(
    args.state.start_x, args.state.start_y,
    args.state.end_x, args.state.end_y,
    path
  )

  args.state.path = path
  args.state.path_dist = dist
end

WALL_COLOR = { r: 200, g: 200, b: 210 }
FLOOR_COLOR = { r: 40, g: 40, b: 50 }
BG_COLOR = { r: 20, g: 20, b: 30 }
PATH_COLOR = { r: 100, g: 200, b: 255, a: 255 }

def render(args)
  args.outputs.background_color = BG_COLOR

  # Draw grid cells
  gd = args.state.grid_data
  s = args.outputs.solids
  y = -1
  while (y += 1) < GRID_SIZE
    x = -1
    while (x += 1) < GRID_SIZE
      cell_x = GRID_OFFSET_X + x * CELL_SIZE
      cell_y = GRID_OFFSET_Y + y * CELL_SIZE

      idx = y * GRID_SIZE + x
      is_wall = gd[idx] == 1

      next unless is_wall

      s << { x: cell_x, y: cell_y, w: CELL_SIZE, h: CELL_SIZE, **WALL_COLOR }
    end
  end

  # Draw path
  if args.state.path.length > 0
    # Draw path segments
    # Swap path coordinates to match grid system
    pa = args.state.path
    ll = args.outputs.lines
    l = pa.length - 2
    i = 0
    while i < l
      x1 = GRID_OFFSET_X + pa[i + 1] * CELL_SIZE + CELL_SIZE / 2
      y1 = GRID_OFFSET_Y + pa[i] * CELL_SIZE + CELL_SIZE / 2
      x2 = GRID_OFFSET_X + pa[i + 3] * CELL_SIZE + CELL_SIZE / 2
      y2 = GRID_OFFSET_Y + pa[i + 2] * CELL_SIZE + CELL_SIZE / 2

      ll << { x: x1, y: y1, x2: x2, y2: y2, **PATH_COLOR }
      i += 2
    end

    # Draw waypoints
    i = 0
    l = pa.length
    while i < l
      x = GRID_OFFSET_X + pa[i + 1] * CELL_SIZE + CELL_SIZE / 2
      y = GRID_OFFSET_Y + pa[i] * CELL_SIZE + CELL_SIZE / 2

      args.outputs.solids << { x: x - 2, y: y - 2, w: 4, h: 4, **PATH_COLOR }
      i += 2
    end
  end

  # Draw start point (green)
  # Swap x and y to match grid coordinate system
  start_x = GRID_OFFSET_X + args.state.start_y * CELL_SIZE
  start_y = GRID_OFFSET_Y + args.state.start_x * CELL_SIZE
  args.outputs.solids << [start_x, start_y, CELL_SIZE, CELL_SIZE, 100, 255, 100]

  # Draw end point (red)
  end_x = GRID_OFFSET_X + args.state.end_y * CELL_SIZE
  end_y = GRID_OFFSET_Y + args.state.end_x * CELL_SIZE
  args.outputs.solids << [end_x, end_y, CELL_SIZE, CELL_SIZE, 255, 100, 100]

  # Draw instructions
  y_pos = 720 - 30
  args.outputs.labels << [700, y_pos, "L1 Pathfinding Demo", 0, 0, 255, 255, 255]
  y_pos -= 25
  args.outputs.labels << [700, y_pos, "Click: Toggle walls", 0, 0, 200, 200, 200]
  y_pos -= 20
  args.outputs.labels << [700, y_pos, "Drag: Move start (green) or end (red)", 0, 0, 200, 200, 200]
  y_pos -= 20
  args.outputs.labels << [700, y_pos, "R: Generate new maze", 0, 0, 200, 200, 200]
  y_pos -= 20
  args.outputs.labels << [700, y_pos, "C: Clear grid", 0, 0, 200, 200, 200]

  # Draw path distance
  if args.state.path_dist == Float::INFINITY
    dist_text = "No path found!"
    color = [255, 100, 100]
  else
    dist_text = "Path distance: #{args.state.path_dist}"
    color = [100, 255, 100]
  end
  args.outputs.labels << [10, 35, dist_text, 0, 0, *color]
end
