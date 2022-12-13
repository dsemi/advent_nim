import fusion/matching
import re
import sequtils
import strutils

import "../utils"

proc solve(input: string, p2: bool): int =
  var coords: seq[(Coord, Coord)]
  var maxX, maxY = 0
  for line in input.splitlines:
    [@x0, @y0, @x1, @y1] := line.findAll(re"\d+").map(parseInt)
    maxX = max(maxX, max(x0, x1))
    maxY = max(maxY, max(y0, y1))
    coords.add(((x0, y0), (x1, y1)))
  var grid = newSeqWith(maxX+1, newSeq[int](maxY+1))
  for (c0, c1) in coords:
    var c = c0
    if not p2 and c.x != c1.x and c.y != c1.y:
      continue
    let d = (c1 - c).sgn
    while c != c1 + d:
      grid[c] += 1
      c += d
  for row in grid:
    for v in row:
      if v > 1:
        inc result

proc part1*(input: string): int =
  solve(input, false)

proc part2*(input: string): int =
  solve(input, true)
