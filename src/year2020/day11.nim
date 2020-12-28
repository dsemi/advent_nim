import math
import sequtils
import strutils

proc stabilize(input: string, p2: bool = false): int =
  var grid = input.splitlines.mapIt(toSeq(it))
  var changed = true
  while changed:
    changed = false
    # Makes a copy
    var grid2 = grid
    for r in grid.low .. grid.high:
      for c in grid[0].low .. grid[0].high:
        var adjsOcc = 0
        for dr in [-1, 0, 1]:
          for dc in [-1, 0, 1]:
            if dr != 0 or dc != 0:
              var rr = r + dr
              var cc = c + dc
              while p2 and 0 <= rr and rr < grid.len and 0 <= cc and cc < grid[0].len and grid[rr][cc] == '.':
                rr += dr
                cc += dc
              if 0 <= rr and rr < grid.len and 0 <= cc and cc < grid[0].len:
                adjs_occ += int(grid[rr][cc] == '#')
        if grid[r][c] == 'L' and adjs_occ == 0:
          grid2[r][c] = '#'
          changed = true
        elif grid[r][c] == '#' and adjs_occ >= (if p2: 5 else: 4):
          grid2[r][c] = 'L'
          changed = true
    grid = grid2
  grid.mapIt(it.count('#')).sum

proc part1*(input: string): int =
  stabilize(input)

proc part2*(input: string): int =
  stabilize(input, true)
