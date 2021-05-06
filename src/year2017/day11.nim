import sequtils
import strutils

import "../utils"

proc distFromOrigin(pos: Coord3): int =
  [pos.x, pos.y, pos.z].mapIt(it.abs).max

proc ap(d: string, p: Coord3): Coord3 =
  case d:
    of "n":  (0, 1, -1) + p
    of "ne": (1, 0, -1) + p
    of "se": (1, -1, 0) + p
    of "s":  (0, -1, 1) + p
    of "sw": (-1, 0, 1) + p
    of "nw": (-1, 1, 0) + p
    else: raiseAssert "Parse error: " & d

proc path(input: string): seq[Coord3] =
  result = @[(0, 0, 0)]
  for d in input.split(','):
    result.add(ap(d, result[^1]))

proc part1*(input: string): int =
  input.path[^1].distFromOrigin

proc part2*(input: string): int =
  input.path.map(distFromOrigin).max
