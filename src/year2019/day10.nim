import algorithm
import math
import sequtils
import strutils
import tables

import "../utils"

proc parse(input: string): seq[Coord] =
  for y, line in toSeq(input.splitLines):
    for x, v in line:
      if v == '#':
        result.add((x, y))

proc dist(a, b: Coord): int =
  (b - a).abs.sum

proc theta(a, b: Coord): float =
  let (x, y) = b - a
  arctan2(-x.float, y.float)

proc visibilities(pt: Coord, pts: seq[Coord]): seq[seq[Coord]] =
  var m: Table[float, seq[Coord]]
  for p in pts:
    if p != pt:
      m.mgetOrPut(pt.theta(p), @[]).add(p)
  for k in toSeq(m.keys).sorted:
    result.add(m[k].sortedByIt(pt.dist(it)))

proc maxDetected(asts: seq[Coord]): seq[seq[Coord]] =
  var mx = int.low
  for ast in asts:
    let v = ast.visibilities(asts)
    if v.len > mx:
      mx = v.len
      result = v

proc part1*(input: string): int =
  input.parse.maxDetected.len

proc part2*(input: string): int =
  var m = input.parse.maxDetected
  var i = 0
  while true:
    for pts in m.mitems:
      if pts.len > 0:
        inc i
        if i == 200:
          let (a, b) = pts[0]
          return 100 * a + b
        pts = pts[1..^1]
