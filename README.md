# L1 Pathfinding for DragonRuby

A DragonRuby Game Toolkit implementation of L1 pathfinding algorithms for optimal grid-based pathfinding using Manhattan distance.

This is a Ruby translation of JavaScript libraries for L1 pathfinding, featuring:
- A* search with landmark-based heuristics
- Spatial partitioning for efficient vertex queries
- Geometry-aware obstacle detection
- Interactive visual demo

## Requirements

- DragonRuby Game Toolkit 6.x Pro Edition

## Usage Example

**IMPORTANT:** Make sure to require files in the correct order - `lib/vertex` must come before `lib/graph`.

```ruby
# Required files in correct order
require 'lib/serializable'
require 'lib/nd_array'
require 'lib/geometry'
require 'lib/contour_2d'
require 'lib/orient'
require 'lib/uniq'
require 'lib/nd_array_ops'
require 'lib/prefix_sum'
require 'lib/vertex'      # Must come before graph
require 'lib/graph'
require 'lib/planner'

# Create a grid with walls (0 = passable, 1 = wall)
# Grid is specified in row-major order
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
planner = createPlanner(grid)

# Find a path from (0, 0) to (7, 6)
# Coordinates are (x, y) where x is column, y is row
# Path must navigate around the walls
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
```

### Grid Format

- **0** = passable cell
- **1** = wall/obstacle
- Grid data is specified in **row-major order**: `[row0_col0, row0_col1, ..., row1_col0, row1_col1, ...]`
- Coordinates are **(x, y)** where x is the column index and y is the row index
- Grid shape is specified as **[num_rows, num_columns]**

## Running the Demo

```bash
./run
```

This launches an interactive pathfinding visualization where you can:
- **Click**: Toggle walls on/off
- **Drag green square**: Move the start point
- **Drag red square**: Move the end point
- **R key**: Generate a new random maze
- **C key**: Clear the grid (creates empty grid with border)

The blue line shows the optimal L1 path from start to end. If no path exists, you'll see "No path found!" in red.

## Running Tests

Run all tests:
```bash
./test
```

Run a specific test file:
```bash
./test planner
./test graph
./test vertex
```

Run a specific test by line number:
```bash
./test planner:15
```

Run tests matching a name pattern:
```bash
./test planner#basic
```

## Project Structure

**Core Pathfinding:**
- `lib/vertex.rb` - Graph vertices with pairing heap and A* state tracking
- `lib/graph.rb` - A* pathfinding with landmark heuristics
- `lib/planner.rb` - High-level pathfinding interface with spatial partitioning
- `lib/geometry.rb` - Obstacle detection and collision checking

**Utilities:**
- `lib/nd_array.rb` - N-dimensional array operations
- `lib/permutations.rb` - Permutation utilities
- `lib/iota_array.rb` - Sequential array generation
- `lib/orient.rb` - Orientation tests for geometry
- `lib/contour_2d.rb` - Contour extraction from grids
- `lib/binary_search_bounds.rb` - Binary search operations

**Demo:**
- `app/main.rb` - Interactive visualization demo

**Tests:**
- `tests/` - Test suite for all modules

## Algorithm Overview

The L1 pathfinding algorithm:
1. Extracts corner vertices from the obstacle grid
2. Builds a visibility graph using spatial partitioning
3. Uses A* search with landmark-based lower bounds for optimal paths
4. Returns Manhattan-distance optimal paths that avoid obstacles

See individual source files for detailed implementation notes and comments.
