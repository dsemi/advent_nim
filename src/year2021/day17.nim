import math
import strscans

import "../utils"

proc hitsTarget(x0, x1, y0, y1, vx, vy: int): bool =
  var (vx, vy) = (vx, vy)
  var p: Coord = (0, 0)
  while p.x <= x1 and p.y >= y0:
    p += (vx, vy)
    vx = max(0, vx - 1)
    vy -= 1
    if p.x in x0..x1 and p.y in y0..y1:
      return true

proc part1*(input: string): int =
  var x0, x1, y0, y1: int
  doAssert input.scanf("target area: x=$i..$i, y=$i..$i", x0, x1, y0, y1)
  y0 * (y0 + 1) div 2

proc part2*(input: string): int =
  var x0, x1, y0, y1: int
  doAssert input.scanf("target area: x=$i..$i, y=$i..$i", x0, x1, y0, y1)
  doAssert x0 > 0 and x1 > 0
  doAssert y0 < 0 and y1 < 0
  # First triangular number > x0 is lower bound.
  # n^2 + n - 2x0 = 0
  let mx = ((1 + 8 * x0.float).sqrt / 2 - 0.5).ceil.int
  for x in mx .. x1:
    for y in y0 .. -y0:
      if hitsTarget(x0, x1, y0, y1, x, y):
        inc result
