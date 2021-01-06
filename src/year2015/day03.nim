import math
import sequtils
import sets

import "../utils"

iterator path(input: string): Coord =
  yield (0, 0)
  for c in input:
    case c:
      of '^': yield ( 0,  1)
      of 'v': yield ( 0, -1)
      of '>': yield ( 1,  0)
      of '<': yield (-1,  0)
      else: doAssert false, "bad input"

proc part1*(input: string): int =
  toSeq(path(input)).cumsummed.toHashSet.len

proc part2*(input: string): int =
  var s1, s2 = newSeq[Coord]()
  for i, p in toSeq(path(input)):
    if i mod 2 == 0: s1.add(p)
    else: s2.add(p)
  (s1.cumsummed.toHashSet + s2.cumsummed.toHashSet).len
