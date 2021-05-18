import sequtils
import strutils
import sugar
import tables

import "../utils"

proc parseWires(input: string): seq[Table[Coord, int]] =
  for line in input.splitLines:
    var m: Table[Coord, int]
    var pos = (0, 0)
    var steps = 0
    for p in line.split(','):
      let d = case p[0]:
                of 'U': (0, 1)
                of 'D': (0, -1)
                of 'L': (-1, 0)
                of 'R': (1, 0)
                else: raiseAssert "Unknown direction: " & p
      for _ in 1..p[1..^1].parseInt:
        pos += d
        inc steps
        if pos notin m:
          m[pos] = steps
    result.add(m)

proc part1*(input: string): int =
  let m = input.parseWires.foldl(intersect(a, b))
  toSeq(m.keys).mapIt(it.abs.sum).min

proc part2*(input: string): int =
  let m = input.parseWires.foldl(intersect(a, b, (a, b) => a + b))
  toSeq(m.values).min
