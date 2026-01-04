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
GRID_SIZE = 64
CELL_SIZE = 10
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
end

def init_demo(args)
  # Create grid with maze
  args.state.grid_data = generate_maze(GRID_SIZE, GRID_SIZE)
  args.state.grid = NDArray.new(args.state.grid_data, [GRID_SIZE, GRID_SIZE])

  # Set start and end points
  args.state.start_x = 1
  args.state.start_y = 1
  args.state.end_x = GRID_SIZE - 2
  args.state.end_y = GRID_SIZE - 2

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

def carve_chamber(grid, width, x, y, w, h)
  return if w < 2 || h < 2

  # Carve out the chamber
  (y...(y+h)).each do |cy|
    (x...(x+w)).each do |cx|
      grid[cy * width + cx] = 0
    end
  end

  # Choose random division points
  if w > h
    # Divide vertically
    if w > 3
      div_x = x + 1 + rand(w - 2)
      gap_y = y + rand(h)

      # Create wall
      (y...(y+h)).each do |cy|
        grid[cy * width + div_x] = 1 unless cy == gap_y
      end

      # Recurse
      carve_chamber(grid, width, x, y, div_x - x, h)
      carve_chamber(grid, width, div_x + 1, y, x + w - div_x - 1, h)
    end
  else
    # Divide horizontally
    if h > 3
      div_y = y + 1 + rand(h - 2)
      gap_x = x + rand(w)

      # Create wall
      (x...(x+w)).each do |cx|
        grid[div_y * width + cx] = 1 unless cx == gap_x
      end

      # Recurse
      carve_chamber(grid, width, x, y, w, div_y - y)
      carve_chamber(grid, width, x, div_y + 1, w, y + h - div_y - 1)
    end
  end
end

def generate_maze(width, height)
  # Start with all walls
  grid = Array.new(width * height, 1)

  # Generate maze with border
  carve_chamber(grid, width, 1, 1, width - 2, height - 2)

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
  if args.state.needs_planner_update
    # Ensure start and end positions are clear in grid
    start_idx = args.state.start_y * GRID_SIZE + args.state.start_x
    end_idx = args.state.end_y * GRID_SIZE + args.state.end_x
    args.state.grid_data[start_idx] = 0
    args.state.grid_data[end_idx] = 0

    # Recreate grid and planner
    args.state.grid = NDArray.new(args.state.grid_data, [GRID_SIZE, GRID_SIZE])
    args.state.planner = createPlanner(args.state.grid)
    args.state.needs_planner_update = false
  end

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

def render(args)
  args.outputs.background_color = [20, 20, 30]

  # Draw grid cells
  GRID_SIZE.times do |y|
    GRID_SIZE.times do |x|
      cell_x = GRID_OFFSET_X + x * CELL_SIZE
      cell_y = GRID_OFFSET_Y + y * CELL_SIZE

      idx = y * GRID_SIZE + x
      is_wall = args.state.grid_data[idx] == 1

      # Cell background
      color = is_wall ? [200, 200, 210] : [40, 40, 50]
      args.outputs.solids << [cell_x, cell_y, CELL_SIZE, CELL_SIZE, *color]

      # Cell border
      args.outputs.borders << [cell_x, cell_y, CELL_SIZE, CELL_SIZE, 210, 210, 220]
    end
  end

  # Draw path
  if args.state.path.length > 0
    # Draw path segments
    # Swap path coordinates to match grid system
    i = 0
    while i < args.state.path.length - 2
      x1 = GRID_OFFSET_X + args.state.path[i + 1] * CELL_SIZE + CELL_SIZE / 2
      y1 = GRID_OFFSET_Y + args.state.path[i] * CELL_SIZE + CELL_SIZE / 2
      x2 = GRID_OFFSET_X + args.state.path[i + 3] * CELL_SIZE + CELL_SIZE / 2
      y2 = GRID_OFFSET_Y + args.state.path[i + 2] * CELL_SIZE + CELL_SIZE / 2

      args.outputs.lines << [x1, y1, x2, y2, 100, 200, 255, 255]
      i += 2
    end

    # Draw waypoints
    i = 0
    while i < args.state.path.length
      x = GRID_OFFSET_X + args.state.path[i + 1] * CELL_SIZE + CELL_SIZE / 2
      y = GRID_OFFSET_Y + args.state.path[i] * CELL_SIZE + CELL_SIZE / 2

      args.outputs.solids << [x - 3, y - 3, 6, 6, 100, 200, 255]
      i += 2
    end
  end

  # Draw start point (green)
  # Swap x and y to match grid coordinate system
  start_x = GRID_OFFSET_X + args.state.start_y * CELL_SIZE
  start_y = GRID_OFFSET_Y + args.state.start_x * CELL_SIZE
  args.outputs.solids << [start_x + 2, start_y + 2, CELL_SIZE - 4, CELL_SIZE - 4, 100, 255, 100]
  args.outputs.labels << [start_x + CELL_SIZE / 2, start_y + CELL_SIZE / 2 + 4, 'S', 0, 1, 0, 0, 0, 255]

  # Draw end point (red)
  end_x = GRID_OFFSET_X + args.state.end_y * CELL_SIZE
  end_y = GRID_OFFSET_Y + args.state.end_x * CELL_SIZE
  args.outputs.solids << [end_x + 2, end_y + 2, CELL_SIZE - 4, CELL_SIZE - 4, 255, 100, 100]
  args.outputs.labels << [end_x + CELL_SIZE / 2, end_y + CELL_SIZE / 2 + 4, 'E', 0, 1, 255, 255, 255, 255]

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

  args.outputs.primitives << GTK.framerate_diagnostics_primitives
end
