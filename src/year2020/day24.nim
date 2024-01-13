import re
import sequtils
import sets
import strutils
import tables

import "../utils"

let dirs = {
  "e" : (1, -1),
  "se": (0, -1),
  "sw": (-1, 0),
  "w" : (-1, 1),
  "nw": (0, 1),
  "ne": (1, 0),
}.toTable

proc flipTiles(input: string): HashSet[Coord] =
  let m = toSeq(dirs.keys).join("|").re
  for line in input.splitlines:
    var coord = (0, 0)
    for d in findAll(line, m):
      coord += dirs[d]
    result = result -+- toHashSet([coord])

proc part1*(input: string): int =
  flipTiles(input).len

const steps = 100

proc part2*(input: string): int =
  var tiles = flipTiles(input)
  var minX, minY = int.high
  var maxX, maxY = int.low
  for coord in tiles:
    minX = min(minX, coord[0])
    minY = min(minY, coord[1])
    maxX = max(maxX, coord[0])
    maxY = max(maxY, coord[1])
  let xOffset = -minX + steps + 1
  let yOffset = -minY + steps + 1
  minX += xOffset
  minY += yOffset
  maxX += xOffset
  maxY += yOffset
  var grid = newSeqWith(maxY+steps+2, newSeq[bool](maxX+steps+2))
  for tile in tiles:
    grid[tile[1] + yOffset][tile[0] + xOffset] = true
  # Switch to 1d and deepcopy wouldn't be required.
  var grid2: seq[seq[bool]]
  deepcopy(grid2, grid)
  for _ in 1..steps:
    dec minX
    dec minY
    inc maxX
    inc maxY
    for r in minY..maxY:
      for c in minX..maxX:
        var adj = 0
        for d in [(1, -1), (0, -1), (-1, 0), (-1, 1), (0, 1), (1, 0)]:
          if grid[r+d[1]][c+d[0]]:
            inc adj
        if grid[r][c]:
          grid2[r][c] = adj != 0 and adj <= 2
        else:
          grid2[r][c] = adj == 2
    swap(grid, grid2)
  for row in grid:
    for v in row:
      if v:
        inc result
