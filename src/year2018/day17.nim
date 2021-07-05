import algorithm
import sequtils
import strscans
import strutils
import tables

import "../utils"

type Ground = ref object
  grid: seq[seq[char]]
  offsetX: int
  minY: int
  maxY: int

proc get(ground: Ground, c: Coord): var char {.inline.} =
  ground.grid[c[0] - ground.offsetX][c[1] - ground.minY]

proc parseScans(input: string): Ground =
  var clay: seq[Coord]
  for line in input.splitLines:
    var t: Table[char, seq[int]]
    var c1, c2: char
    var v1, v2a, v2b: int
    doAssert line.scanf("${c}=$i, ${c}=$i..$i", c1, v1, c2, v2a, v2b)
    t[c1] = @[v1]
    t[c2] = toSeq(v2a..v2b)
    for x in t['x']:
      for y in t['y']:
        clay.add((x, y))
  let (x0, y0) = (clay.mapIt(it[0]).min - 1, clay.mapIt(it[1]).min)
  let (x1, y1) = (clay.mapIt(it[0]).max + 1, clay.mapIt(it[1]).max)
  var grid = newSeqWith(x1 - x0 + 1, newSeq[char](y1 - y0 + 1))
  for col in grid.mitems: col.fill('.')
  result = Ground(grid: grid, offsetX: x0, minY: y0, maxY: y1)
  for c in clay:
    result.get(c) = '#'

proc flood(ground: Ground): Ground =
  result = ground
  proc go(ground: var Ground, coord: Coord): bool =
    let (x, y) = coord
    if y < ground.minY: return ground.go((x, y+1))
    if y > ground.maxY: return false
    let c = ground.get(coord)
    if c == '|': return false
    if c == '#': return true
    let blocked = ground.go((x, y+1))
    if not blocked:
      if ground.get(coord) == '.':
        ground.get(coord) = '|'
      return false
    else:
      var lefts, rights: seq[Coord]
      var x2 = x
      while ground.get((x2, y)) != '#' and ground.get((x2, y+1)) in "#~":
        lefts.add((x2, y))
        dec x2
      x2 = x
      while ground.get((x2, y)) != '#' and ground.get((x2, y+1)) in "#~":
        rights.add((x2, y))
        inc x2
      let nextL = lefts[^1] - (1, 0)
      let nextR = rights[^1] + (1, 0)
      if ground.get(nextL) == '#' and ground.get(nextR) == '#':
        for c in lefts & rights: ground.get(c) = '~'
        return true
      else:
        for c in lefts & rights: ground.get(c) = '|'
        let (a, b) = (ground.go(nextL), ground.go(nextR))
        return a and b
  discard result.go((500, 0))

proc part1*(input: string): int =
  for col in input.parseScans.flood.grid:
    for c in col:
      result += int(c in "~|")

proc part2*(input: string): int =
  for col in input.parseScans.flood.grid:
    for c in col:
      result += int(c == '~')
