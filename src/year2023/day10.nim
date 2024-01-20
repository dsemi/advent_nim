import std/bitops
import std/sugar

import "../utils"

const U: uint8 = 0b1000
const L: uint8 = 0b0100
const D: uint8 = 0b0010
const R: uint8 = 0b0001

func turn(dir: uint8, pipe: char): uint8 =
  let dir = ((dir and 3) shl 2) or ((dir and 12) shr 2)
  let pipe = case pipe
             of '|': U or D
             of '-': L or R
             of 'L': U or R
             of 'J': U or L
             of '7': D or L
             of 'F': D or R
             else: raiseAssert "unreachable"
  dir xor pipe

proc coord(dir: uint8): Coord =
  case dir
  of U: (-1, 0)
  of L: (0, -1)
  of D: (1, 0)
  of R: (0, 1)
  else: raiseAssert "unreachable"

proc parse(input: string): (Coord, uint8, Grid[char]) =
  let grid = input.toGrid
  var start: Coord
  block outer:
    for r in 0 ..< grid.rows:
      for c in 0 ..< grid.cols:
        if grid.elems[r*grid.cols + c] == 'S':
          start = (r, c)
          break outer
  var dir: uint8
  for d in [U, L, D, R]:
    let pos = start + coord(d)
    if 0 <= pos.x and pos.x < grid.rows and 0 <= pos.y and pos.y < grid.cols and turn(d, grid.elems[pos.x*grid.cols+pos.y]).countSetBits == 1:
      dir = d
      break
  (start, dir, grid)

iterator mainPts(input: string): Coord =
  var (pos, dir, grid) = parse(input)
  yield pos
  while true:
    pos += coord(dir)
    let v = grid.elems[pos.x*grid.cols+pos.y]
    if v == 'S':
      break
    dir = turn(dir, v)
    yield pos

proc part1*(input: string): int =
  for _ in mainPts(input):
    inc result
  result div 2

proc part2*(input: string): int =
  let pts = collect:
    for pt in mainPts(input):
      pt
  let area = shoelace(pts)
  picksInterior(area, pts.len)
