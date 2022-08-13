import sequtils
import strutils
import sugar

proc parse(input: string): seq[seq[bool]] =
  result = collect(newSeq):
    for row in input.splitLines:
      collect(newSeq):
        for v in row:
          v == '#'

proc step(grid: var seq[seq[bool]]) =
  var neighbs = newSeqWith(grid.len, newSeq[int](grid[0].len))
  for i in grid.low .. grid.high:
    for j in grid[i].low .. grid[i].high:
      for x in [-1, 0, 1]:
        for y in [-1, 0, 1]:
          if x != 0 or y != 0:
            let i2 = i+y
            let j2 = j+x
            if i2 in grid.low .. grid.high and j2 in grid[i2].low .. grid[i2].high and grid[i2][j2]:
              inc neighbs[i][j]
  for i in grid.low .. grid.high:
    for j in grid[i].low .. grid[i].high:
      grid[i][j] = grid[i][j] and neighbs[i][j] in [2, 3] or not grid[i][j] and neighbs[i][j] == 3

proc part1*(input: string): int =
  var grid = parse(input)
  for _ in 1..100:
    grid.step
  for row in grid:
    for v in row:
      result.inc v.int

proc part2*(input: string): int =
  var grid = parse(input)
  grid[0][0] = true
  grid[0][99] = true
  grid[99][0] = true
  grid[99][99] = true
  for _ in 1..100:
    grid.step
    grid[0][0] = true
    grid[0][99] = true
    grid[99][0] = true
    grid[99][99] = true
  for row in grid:
    for v in row:
      result.inc v.int
