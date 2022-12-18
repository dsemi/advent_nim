import sequtils
import sets
import strutils
import sugar

import "../utils"

iterator adj(c: Coord3): Coord3 =
  for d in [(1, 0, 0), (-1, 0, 0), (0, 1, 0), (0, -1, 0), (0, 0, 1), (0, 0, -1)]:
    yield c + d

proc cubes(input: string): HashSet[Coord3] =
  for line in input.splitLines:
    let pts = line.split(",").map(parseInt)
    result.incl (pts[0], pts[1], pts[2])

proc part1*(input: string): int =
  let lava = input.cubes
  for c in lava:
    for a in c.adj:
      result += int(a notin lava)

proc part2*(input: string): int =
  let lava = input.cubes
  var lo: Coord3 = (int.high, int.high, int.high)
  var hi: Coord3 = (int.low, int.low, int.low)
  for c in lava:
    lo = min(lo, c)
    hi = max(hi, c)

  proc neighbors(pos: Coord3): iterator: Coord3 =
    return iterator(): Coord3 =
      for p in p.adj:
        if p.x in lo.x..hi.x and p.y in lo.y..hi.y and p.z in lo.z..hi.z and p notin lava:
          yield p

  let air = collect(for _, c in bfsM([lo, hi], neighbors): {c})
  for c in lava:
    for a in c.adj:
      result += int(a in air)
