import sequtils
import strutils
import sugar

iterator run(input: string): int =
  var grid = input.splitlines.map((line) => line.mapIt(parseInt($it)))
  proc flash(r, c: int): int =
    grid[r][c] = -1
    result = 1
    for r in [r-1, r, r+1]:
      for c in [c-1, c, c+1]:
        if r in 0..<grid.len and c in 0..<grid[r].len and grid[r][c] != -1:
          grid[r][c] += 1
          if grid[r][c] > 9:
            result += flash(r, c)
  for _ in 0..int.high:
    for row in grid.mitems:
      for v in row.mitems:
        v = max(0, v) + 1
    var flashed: int
    for r, row in grid:
      for c, v in row:
        if v > 9:
          flashed += flash(r, c)
    yield flashed

proc part1*(input: string): int =
  var i: int
  for v in run(input):
    result += v
    i += 1
    if i == 100:
      break

proc part2*(input: string): int =
  var i: int
  for v in run(input):
    i += 1
    if v == 100:
      return i
