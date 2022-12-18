import sequtils
import sets
import strutils
import sugar

import "../utils"

proc adj(c: Coord3): seq[Coord3] =
  for d in [(1, 0, 0), (-1, 0, 0), (0, 1, 0), (0, -1, 0), (0, 0, 1), (0, 0, -1)]:
    result.add c + d

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
      for pos2 in pos.adj:
        if pos2.x in lo.x..hi.x and pos2.y in lo.y..hi.y and pos2.z in lo.z..hi.z and pos2 notin lava:
          yield pos2

  let air = collect(for _, c in bfsM([lo, hi], neighbors): {c})
  for c in lava:
    for a in c.adj:
      result += int(a in air)
