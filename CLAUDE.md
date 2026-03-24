# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a DragonRuby Game Toolkit (DRGTK) project implementing L1 pathfinding algorithms. The codebase is a Ruby translation of JavaScript libraries for optimal grid-based pathfinding using the L1 distance metric (Manhattan distance).

**DRGTK Version:** 6.x Pro Edition
**Language:** mRuby (DragonRuby flavor)

## Commands

### Running the Game
```bash
./run
```
This script changes to the parent DragonRuby directory and launches the game.

### Running Tests
```bash
./test [test_file]
```
- Without arguments: runs all tests in `tests/tests.rb`
- With argument: runs specific test file. This will automatically (if needed):
  - prefix with `tests/`,
  - prepend `test_` on the file,
  - append `.rb`
  and you can target specific tests with:
  - append `:123` to run only the test on that line
  - or append `#partial_name` to only run tests that have this in their name
- Tests run with `SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy` for headless execution
- Uses flags: `--test <file> --no-tick`

## Architecture

### Core Pathfinding Components

**Vertex (`lib/vertex.rb`)**
- Multi-purpose data structure that serves as:
  - Graph topology storage
  - Pairing heap implementation (intrusive)
  - Free list for memory management
  - Search state tracking (predecessors, distances, open/closed states)
- Uses a sentinel NIL node pattern
- Key class methods: `create`, `link`, `push`, `pop`, `decrease_key`, `insert`, `clear`
- Implements landmark-based A* heuristics with 16 landmarks per component

**Graph (`lib/graph.rb`)**
- A* pathfinding on vertex graphs
- Landmark-based heuristic optimization for improved search performance
- Key methods:
  - `init`: Finds connected components and computes landmarks
  - `search`: Runs A* algorithm
  - `get_path`: Extracts the path from target to source
  - `add_s`/`add_t`: Marks vertices connected to source/target
  - `find_components`: Identifies disconnected graph regions
  - `find_landmarks`: Computes NUM_LANDMARKS (16) landmarks per component

**Planner (`lib/planner.rb`)** - Work in progress
- High-level pathfinding interface
- Uses spatial partitioning (binary tree with buckets) for efficient vertex queries
- Integrates geometry checking with graph search
- Constants: `LEAF_CUTOFF = 64`, `BUCKET_SIZE = 32`

**Geometry (`lib/geometry.rb`)** - Work in progress
- Handles obstacle detection and collision checking
- Uses integral images for fast box stabbing queries
- Methods: `stabBox`, `stabRay`, `stabTile`
- Extracts corners from grid contours using orientation tests

### Utility Modules

**NDArray (`lib/nd_array.rb`)**
- N-dimensional array implementation (translated from scijs/ndarray)
- Supports shape, stride, and offset for flexible array views
- Operations: `step`, `transpose`, `pick`, `lo`, `hi`, `get`, `set`
- Includes specialized `NilDArray` for 0-dimensional arrays

**Permutations (`lib/permutations.rb`)**
- Functions for permutation manipulation
- `invert`: Inverts a permutation array
- `rank`: Computes lexicographic rank of a permutation
- `unrank`: Generates permutation from its rank

**IotaArray (`lib/iota_array.rb`)**
- Simple utility to generate sequential integer arrays
- `iota(n)` returns `[0, 1, 2, ..., n-1]`

**Serializable (`lib/serializable.rb`)**
- Mixin for DRGTK object serialization

### Test Structure

Tests use DragonRuby's built-in test framework (`$gtk.tests`). Each test file in `tests/` contains functions prefixed with `test_`.

## Code Organization

**Entry Point:** `app/main.rb` requires all necessary files and defines the `tick` method (game loop).

**Translation Status:** This is a partial Ruby translation of JavaScript pathfinding libraries. Several files contain commented-out JavaScript code showing the original implementation. Some modules (`contour_2d.rb`, `binary_search_bounds.rb`) are not yet fully integrated.
