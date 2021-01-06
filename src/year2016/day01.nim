import sets
import strutils

import "../utils"

iterator path(input: string): Coord =
  var pos = (0, 0)
  var dir = (0, 1)
  yield pos
  for d in input.split(", "):
    if d[0] == 'R':
      dir *= (0, -1)
    else:
      dir *= (0, 1)
    for _ in 1 .. d[1 .. ^1].parseInt:
      pos += dir
      yield pos

proc part1*(input: string): int =
  var pos: Coord
  for c in path(input):
    pos = c
  abs(pos.x) + abs(pos.y)

proc part2*(input: string): int =
  var s = initHashSet[Coord]()
  for c in path(input):
    if c in s:
      return abs(c.x) + abs(c.y)
    s.incl(c)
