import algorithm
import math
import sequtils
import strscans
import strutils

import "../utils"

type Nanobot = object
  pos: Coord3
  radius: int

proc parseNanobots(input: string): seq[Nanobot] =
  for line in input.splitLines:
    var x, y, z, r: int
    doAssert line.scanf("pos=<$i,$i,$i>, r=$i", x, y, z, r)
    result.add(Nanobot(pos: (x, y, z), radius: r))

proc inRange(bot: Nanobot, coord: Coord3): bool =
  (bot.pos - coord).abs.sum <= bot.radius

proc part1*(input: string): int =
  let ns = input.parseNanobots
  let maxBot = ns.sortedByIt(it.radius)[^1]
  for bot in ns:
    if maxBot.inRange(bot.pos):
      inc result

proc part2*(input: string): int =
  var ns = input.parseNanobots
  var n = 10_000_000
  var minCoord = floorDiv(ns.mapIt(it.pos).foldl((min(a[0], b[0]), min(a[1], b[1]), min(a[2], b[2]))), n)
  var maxCoord = floorDiv(ns.mapIt(it.pos).foldl((max(a[0], b[0]), max(a[1], b[1]), max(a[2], b[2]))), n)
  var coord: (int, Coord3)
  while n != 0:
    let ns2 = ns.mapIt(Nanobot(pos: floorDiv(it.pos, n), radius: floorDiv(it.radius, n)))
    coord[0] = int.low
    for p in countup(minCoord, maxCoord):
      var cnt: int
      for n in ns2:
        if n.inRange(p):
          inc cnt
      if (cnt, -p) > coord:
        coord = (cnt, -p)
    coord[1] = -coord[1]
    minCoord = 10 * (coord[1] - (1, 1, 1))
    maxCoord = 10 * (coord[1] + (1, 1, 1))
    n = n div 10
  coord[1].sum
