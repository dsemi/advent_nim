import algorithm
import math
import sequtils
import sets
import strutils
import sugar

import "../utils.nim"

iterator neighbs(grid: seq[seq[int]], c: Coord): Coord =
  for d in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
    let c2 = c + d
    if c2.x in 0..<grid.len and c2.y in 0..<grid[c2.x].len:
      yield c2

iterator lows(grid: seq[seq[int]]): Coord =
  for r in 0..<grid.len:
    for c in 0..<grid[r].len:
      var all = true
      for n in neighbs(grid, (r, c)):
        all = all and grid[r][c] < grid[n.x][n.y]
      if all:
        yield (r, c)

proc part1*(input: string): int =
  let grid = input.splitlines.mapIt(it.map((c) => parseInt($c)))
  for (r, c) in lows(grid):
    result += grid[r][c] + 1

proc part2*(input: string): int =
  let grid = input.splitlines.mapIt(it.map((c) => parseInt($c)))
  var visited: HashSet[Coord]
  var basins: seq[int]
  proc ns(c: Coord): iterator: Coord =
    return iterator(): Coord =
      for n in neighbs(grid, c):
        if grid[n.x][n.y] != 9:
          yield n
  for pt in lows(grid):
    var c: int
    for (_, p) in bfs(pt, ns):
      if visited.containsOrIncl(p):
        break
      inc c
    basins.add(c)
  basins.sort
  basins[^3..^1].prod
