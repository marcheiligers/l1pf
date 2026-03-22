# L1PF Optimization Notes

Two phases: **planner creation** (expensive, one-time) and **path search** (per-query). Planner creation dominates.

## Benchmark Results (65x65 seeded maze, 10 create / 1000 search iterations)

| | Baseline | Optimized | Improvement |
|---|---------|-----------|-------------|
| planner_create | 656ms | 480ms | **27% faster** |
| path_search | 1400ms | 1165ms | **17% faster** |

### Changes Applied
1. Replaced `.lesser`/`.greater` with inline ternary in geometry, graph, planner
2. Inlined grid data access in `stab_box` (eliminate `get()` method call + splat)
3. Cached `@grid_data`, `@grid_stride0` as ivars in PathGeometry
4. Replaced `.map` with while loops in `make_tree` bucket construction
5. Cached locals (`geom`, `edges`, `u[0]`, `u[1]`) in `bipartite` and `make_leaf`
6. Direct data access in `prefix_sum` (bypass `get`/`set` methods)
7. Direct data access in `contour_2d.get_parallel_contours`
8. Inlined sort comparators (contour_2d, planner make_partition)
9. Inlined `heuristic()` method into `search()` loop
10. Cached `method(:compare_bucket)` in L1PathPlanner constructor
11. Cached `v.x`/`v.y` as locals in `find_landmarks` Dijkstra loop
12. Flat edge array (push u,v separately instead of `[u,v]` pairs)
13. Removed unnecessary `.to_i` calls in search

## Hot Path Summary

### Planner Creation (Tier 1)
1. `Geometry.create_geometry` — contour extraction, integral image construction
2. `PlannerBuilder.make_tree` — recursive spatial partitioning, builds bucket tree
3. `PlannerBuilder.make_leaf` — O(n²) visibility checks per leaf (n < 64)
4. `PlannerBuilder.bipartite` — O(a*b) visibility checks, called 3x per bucket
5. `Graph.init` → `find_components` + `find_landmarks` — 16 Dijkstras per component

### Path Search (Tier 2)
1. `Graph.search` — A* main loop with pairing heap
2. `Graph.heuristic` — 16-iteration landmark loop per node expansion
3. `Vertex.pop` — pairing heap extract-min
4. `L1PathPlanner.connect_nodes` — tree traversal to activate vertices

### Shared Critical Method
- `PathGeometry.stab_box` — called thousands of times in both phases (visibility checks during build, ray checks during search setup). Every microsecond here compounds.

---

## Optimization Opportunities

### 1. Eliminate NDArray overhead in stab_box

`stab_box` is THE hottest method. Currently it calls `@grid.get(x, y)` four times, each of which does:
```ruby
@data[@offset + @stride[0] * pos[0] + @stride[1] * pos[1]]
```
With a standard row-major TwoDArray (stride=[cols,1], offset=0), this is just `@data[x * cols + y]`. We could:

- **Cache `@grid.data`, `@grid.stride[0]` as locals** in `stab_box` (or as `@grid_data`, `@grid_stride0` ivars in PathGeometry) to avoid method dispatch + splat args on every call.
- **Better**: since the integral image is always a fresh non-transposed TwoDArray, replace `@grid.get(x,y)` with direct `@grid_data[x * @grid_cols + y]` — eliminates the method call entirely.
- The `*pos` splat in `get(*pos)` allocates an Array on every call. Replacing with a two-arg method `get2(x,y)` or inlining avoids this.

### 2. Replace `.lesser` / `.greater` with inline min/max

`.lesser` and `.greater` are method calls on Numeric. In `stab_box`, there are **8** `.lesser` calls and **2** `.greater` calls per invocation. These are in the hottest loop. Replace with:
```ruby
# Instead of: lox = ax.lesser(bx)
lox = ax < bx ? ax : bx
```
This avoids method dispatch overhead entirely. Same for `.greater`.

### 3. Replace `.map` in make_tree with while loops

`planner.rb:273-275` has three `.map` calls inside the bucket-building loop:
```ruby
bb[:left].map { |v| make_vertex(v) }
bb[:right].map { |v| make_vertex(v) }
bb[:on].map { |v| make_vertex(v) }
```
Each `.map` creates a new Array and involves block dispatch per element. Replace with while loops that build the arrays manually.

### 4. Reduce Hash allocation in make_bucket / make_partition

`make_bucket` returns a Hash with 7 keys, `make_partition` returns a Hash with 5 keys. These are called repeatedly during tree construction. Options:
- Use Struct instead of Hash (faster field access, no string/symbol hashing)
- Or return multiple values and destructure (avoids allocation altogether)

### 5. Inline stab_box into visibility checks

In `make_leaf` and `bipartite`, every iteration calls `@geom.stab_box(u[0], u[1], v[0], v[1])`. The method dispatch + array indexing on `u[0]`, `u[1]` adds up. Consider:
- Storing corners as flat x,y pairs instead of [x,y] arrays (avoids array indexing)
- Inlining the stab_box logic into the visibility loop (eliminates method call)

### 6. Avoid repeated array indexing in tight loops

In `bipartite`:
```ruby
while (j += 1) < bl
  v = b[j]
  @edges.push([u,v]) unless @geom.stab_box(u[0], u[1], v[0], v[1])
end
```
`u[0]` and `u[1]` are recomputed every inner iteration. Cache as locals:
```ruby
ux = u[0]; uy = u[1]
```

### 7. Consider whether NDArray is needed at all

NDArray is used for:
1. **Input grid** — the obstacle grid passed by the user
2. **Transposed view** — `grid.transpose(1,0)` for contour extraction (zero-copy stride swap)
3. **Integral image** — TwoDArray for `stab_box` queries
4. **NDArrayOps** — `ops_gts` (binarize) and `prefix_sum`

The transpose is the only "fancy" feature used. If contour extraction is rewritten to accept row-major data and shape directly (swapping its own x/y indexing), we could replace TwoDArray with a simple class that holds `@data`, `@rows`, `@cols` and does `@data[x * @cols + y]`. This eliminates:
- Stride multiplication on every `get`
- The `*pos` splat allocation
- The entire NDArray inheritance chain

The integral image and prefix_sum could operate directly on a flat Array with known dimensions.

### 8. Reduce allocations in edge collection

`@edges.push([u,v])` in make_leaf, bipartite, and make_bucket creates a 2-element Array for every visible pair. These are later iterated to call `Vertex.link`. Consider:
- Linking vertices immediately instead of collecting edges (eliminates the intermediate array and the second pass)
- Or pre-allocating the edges array if size is estimable

### 9. Graph.heuristic — avoid method call per landmark

```ruby
while (i += 1) < Vertex::NUM_LANDMARKS
  pi = pi.greater(tdist[i] - ndist[i])
end
```
Replace `pi.greater(x)` with `d = tdist[i] - ndist[i]; pi = d > pi ? d : pi`. This eliminates 16 method calls per node expansion.

### 10. prefix_sum uses get/set methods

`prefix_sum.rb` calls `array.get(i, j)` and `array.set(i, j, val)` in tight nested loops over the entire grid. Each call goes through `*pos` splat + stride math. For a 100x100 grid that's ~20,000 get/set calls. Operating directly on `array.data` with manual index math would be significantly faster.

### 11. contour_2d uses get in tight loops

`get_parallel_contours` calls `array.get(i, j)` for every cell in the grid. Same splat/stride overhead. Direct data access with precomputed stride would help.

### 12. Permutations: .downto / .upto blocks

`permutations.rb` uses `.downto` and `.upto` with blocks. Not in a hot path (called once during init), but could be while loops for consistency. **Low priority.**

### 13. sort! with block in make_partition

`on.sort! { |a, b| compare_pair(a, b) }` has a method call per comparison. Could inline the comparison:
```ruby
on.sort! { |a, b| d = a[1] - b[1]; d == 0 ? a[0] - b[0] : d }
```

### 14. BSearch.lt uses method(:compare_bucket)

`method(:compare_bucket)` creates a Method object. In `connect_nodes`, this is called per tree traversal step. Cache the method reference or inline the comparison.

---

## Priority Order

| # | Change | Impact | Effort | Phase |
|---|--------|--------|--------|-------|
| 1 | Inline grid access in stab_box (eliminate get + splat) | Very High | Medium | Both |
| 2 | Replace .lesser/.greater with ternary | High | Low | Both |
| 9 | Inline .greater in heuristic | High | Low | Search |
| 6 | Cache u[0], u[1] as locals in bipartite/make_leaf | Medium | Low | Build |
| 3 | Replace .map with while in make_tree | Medium | Low | Build |
| 10 | Direct data access in prefix_sum | Medium | Medium | Build |
| 11 | Direct data access in contour_2d | Medium | Medium | Build |
| 7 | Replace NDArray with simple grid class | High | High | Both |
| 5 | Inline stab_box into visibility loops | High | High | Build |
| 4 | Struct instead of Hash for bucket/partition | Medium | Medium | Build |
| 8 | Link edges immediately vs collecting | Medium | Medium | Build |
| 13 | Inline sort comparator | Low | Low | Build |
| 14 | Cache method reference for BSearch | Low | Low | Search |
| 12 | While loops in permutations | Negligible | Low | Build |

Items 1, 2, 9, 6, 3 are quick wins. Item 7 is the biggest structural change but yields the most if we commit to it — every `get` call in every hot path gets faster.
