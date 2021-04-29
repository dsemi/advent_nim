import math
import sequtils
import strutils

import "../utils"

proc stabilize(input: string, p2: bool = false): int =
  var grid = input.splitlines.mapIt(toSeq(it))
  var seats = newSeq[(Coord, seq[Coord])]()
  for r, row in grid:
    for c, v in row:
      if v != 'L':
        continue
      var coord = (r, c)
      var neighbs = newSeq[Coord]()
      for dr in [-1, 0, 1]:
        for dc in [-1, 0, 1]:
          if dr == 0 and dc == 0:
            continue
          let drc = (dr, dc)
          var start = coord + drc
          while p2 and
                start[0] in grid.low..grid.high and
                start[1] in grid[0].low..grid[0].high and
                grid[start[0]][start[1]] != 'L':
            start += drc
          if start[0] in grid.low..grid.high and
             start[1] in grid[0].low..grid[0].high and
             grid[start[0]][start[1]] == 'L':
            neighbs.add(start)
      seats.add((coord, neighbs))
  var changed = true
  while changed:
    changed = false
    # Makes a copy
    var grid2 = grid
    for (coord, adjs) in seats:
      let adjsOcc = adjs.countIt(grid[it[0]][it[1]] == '#')
      if grid[coord[0]][coord[1]] == 'L' and adjsOcc == 0:
        grid2[coord[0]][coord[1]] = '#'
        changed = true
      elif grid[coord[0]][coord[1]] == '#' and adjsOcc >= (if p2: 5 else: 4):
        grid2[coord[0]][coord[1]] = 'L'
        changed = true
    grid = grid2
  grid.mapIt(it.count('#')).sum

proc part1*(input: string): int =
  stabilize(input)

proc part2*(input: string): int =
  stabilize(input, true)
