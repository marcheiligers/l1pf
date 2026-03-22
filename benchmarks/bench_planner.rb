require 'lib/l1pf'
require 'app/interactive'

BENCH_SIZE = 65

def tick(args)
  if args.tick_count == 1
    # Use fixed seed for reproducible benchmarks
    srand(12345)
    grid_data = generate_maze(BENCH_SIZE, BENCH_SIZE)
    grid = TwoDArray.new(grid_data, [BENCH_SIZE, BENCH_SIZE])

    # Benchmark planner creation
    GTK.benchmark iterations: 10,
      planner_create: -> { Planner.create(grid) }

    # Create planner once for search benchmarks
    planner = Planner.create(grid)

    # Benchmark path search
    GTK.benchmark iterations: 1000,
      path_search: -> { planner.search(1, 1, BENCH_SIZE - 2, BENCH_SIZE - 2) }

    GTK.request_quit
  end
end
