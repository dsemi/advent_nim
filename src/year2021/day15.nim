import sequtils
import strutils
import sugar

import "../utils.nim"

proc neighbs(grid: seq[seq[int]]): auto =
  return proc(pos: Coord): iterator(): (int, Coord) =
    return iterator(): (int, Coord) =
      for d in [(1, 0), (0, 1), (-1, 0), (0, -1)]:
        let p = pos + d
        if p.x in 0 ..< grid.len and p.y in 0 ..< grid[p.x].len:
          yield (grid[p.x][p.y], p)

proc part1*(input: string): int =
  let grid = input.splitlines.map((line) => line.mapIt(it.ord - '0'.ord))
  for (d, p) in dijkstra((0, 0), neighbs(grid)):
    if p == (grid.len - 1, grid.len - 1):
      return d

proc part2*(input: string): int =
  var grid = input.splitlines.map((line) => line.mapIt(it.ord - '0'.ord))
  let (rows, cols) = (grid.len, grid[0].len)
  for row in grid.mitems:
    for i in 1 .. 4:
      row.add(row[0..<cols].mapIt((it + i - 1) mod 9 + 1))
  for i in 1 .. 4:
    for row in grid[0..<rows]:
      grid.add(row.mapIt((it + i - 1) mod 9 + 1))
  for (d, p) in dijkstra((0, 0), neighbs(grid)):
    if p == (grid.len - 1, grid.len - 1):
      return d
