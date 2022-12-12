import std/enumerate
import strutils

import "../utils"

proc solve(input: string, p2: bool): int =
  var starts = newSeq[Coord]()
  var done: Coord
  var grid: seq[seq[int]]
  for r, line in enumerate(input.splitLines):
    grid.add newSeq[int]()
    for c, v in line:
      case v
      of 'S':
        starts.add (r, c)
        grid[^1].add(0)
      of 'E':
        done = (r, c)
        grid[^1].add(25)
      else:
        if p2 and v == 'a':
          starts.add (r, c)
        grid[^1].add(v.ord - 'a'.ord)

  proc neighbors(pos: Coord): iterator: Coord =
    return iterator(): Coord =
      let currH = grid[pos.x][pos.y]
      for d in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
        let pos2 = d + pos
        if pos2.x in grid.low..grid.high and
           pos2.y in grid[0].low..grid[0].high and
           grid[pos2.x][pos2.y] <= currH + 1:
          yield pos2

  for (d, p) in bfsM(starts, neighbors):
    if p == done:
      return d

proc part1*(input: string): int =
  input.solve(false)

proc part2*(input: string): int =
  input.solve(true)
