import fusion/matching
import math
import sequtils
import strutils
import tables

import "../utils"

proc parseCoords(input: string): seq[Coord] =
  for line in input.splitLines:
    [@a, @b] := line.split(", ").map(parseInt)
    result.add((a, b))

proc dist(a, b: Coord): int =
  (a - b).abs.sum

iterator allWithin(xs: seq[Coord], buffer: int): Coord =
  var (x0, y0, x1, y1) = (int.high, int.high, int.low, int.low)
  for x in xs:
    x0 = min(x0, x[0])
    y0 = min(y0, x[1])
    x1 = max(x1, x[0])
    y1 = max(y1, x[1])
  x0 -= buffer
  y0 -= buffer
  x1 += buffer
  y1 += buffer
  for v in countup((x0, y0), (x1, y1)):
    yield v

proc part1*(input: string): int =
  let coords = input.parseCoords
  var ns: seq[seq[int]]
  for i in [0, 10]:
    var t: CountTable[Coord]
    for coord in coords.allWithin(i):
      let dists = coords.mapIt((dist(coord, it), it))
      let d = dists.min
      if dists.filterIt(it[0] == d[0]).len == 1:
        t.inc(d[1])
    ns.add(toSeq(t.values))
  ns[0].zip(ns[1]).mapIt(if it[0] == it[1]: it[0] else: 0).max

proc part2*(input: string): int =
  let n = 10_000
  let coords = input.parseCoords
  for x in coords.allWithin(n div coords.len):
    if coords.mapIt(dist(x, it)).sum < n:
      inc result
