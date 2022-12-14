import algorithm
import strscans
import strutils

import "../utils"

const width = 1000

proc parseGrid(input: string): seq[seq[char]] =
  for line in input.splitLines:
    var pts = newSeq[Coord]()
    for pt in line.split(" -> "):
      var r, c: int
      doAssert pt.scanf("$i,$i", c, r)
      while result.len < r+2:
        result.add newSeq[char](width)
        result[^1].fill('.')
      pts.add (r, c)
    for i in 1..pts.high:
      for pt in countup(min(pts[i-1], pts[i]), max(pts[i-1], pts[i])):
        result[pt] = '#'

proc flowSand(grid: seq[seq[char]], p2: bool): int =
  var grid = grid
  proc go(grid: var seq[seq[char]], coord: Coord): bool =
    let (r, c) = coord
    if r >= grid.len: return p2
    let v = grid[r][c]
    if v == '~': return false
    if v == '#' or v == 'o': return true
    result = grid.go((r+1, c)) and grid.go((r+1, c-1)) and grid.go((r+1, c+1))
    grid[r][c] = if result: 'o' else: '~'
  discard grid.go((0, 500))
  for row in grid:
    for v in row:
      result += int(v == 'o')

proc part1*(input: string): int =
  input.parseGrid.flowSand(false)

proc part2*(input: string): int =
  input.parseGrid.flowSand(true)
