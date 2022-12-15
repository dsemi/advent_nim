import sequtils
import strscans
import strutils except repeat

import "../utils"

const width = 1000

proc parseGrid(input: string): seq[seq[char]] =
  for line in input.splitLines:
    var pts = newSeq[Coord]()
    for pt in line.split(" -> "):
      var x, y: int
      doAssert pt.scanf("$i,$i", x, y)
      while result.len < y+2:
        result.add repeat('.', width)
      pts.add (x, y)
    for i in 1..pts.high:
      for pt in countup(min(pts[i-1], pts[i]), max(pts[i-1], pts[i])):
        result[pt.y][pt.x] = '#'

proc flowSand(grid: seq[seq[char]], p2: bool): int =
  var grid = grid
  proc go(rest: var int, x, y: int): bool =
    if y >= grid.len: return p2
    if grid[y][x] == '~': return false
    if grid[y][x] in "#o": return true
    result = rest.go(x, y+1) and rest.go(x-1, y+1) and rest.go(x+1, y+1)
    if result: grid[y][x] = 'o'; inc rest
    else: grid[y][x] = '~'
  discard result.go(500, 0)

proc part1*(input: string): int =
  input.parseGrid.flowSand(false)

proc part2*(input: string): int =
  input.parseGrid.flowSand(true)
