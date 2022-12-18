import sequtils
import sets
import strutils

import "../utils"

proc adj(c: Coord3): seq[Coord3] =
  for d in [(1, 0, 0), (-1, 0, 0), (0, 1, 0), (0, -1, 0), (0, 0, 1), (0, 0, -1)]:
    result.add c + d

proc part1*(input: string): int =
  var space = initHashSet[Coord3]()
  for line in input.splitLines:
    let pts = line.split(",").map(parseInt)
    let c = (pts[0], pts[1], pts[2])
    result += 6
    for c2 in c.adj:
      if c2 in space:
        result -= 2
    space.incl(c)

proc part2*(input: string): int =
  var space = initHashSet[Coord3]()
  for line in input.splitLines:
    let pts = line.split(",").map(parseInt)
    space.incl((pts[0], pts[1], pts[2]))
  var (minX, maxX) = (int.high, int.low)
  var (minY, maxY) = (int.high, int.low)
  var (minZ, maxZ) = (int.high, int.low)
  for c in space:
    minX = min(minX, c.x - 1)
    maxX = max(maxX, c.x + 1)
    minY = min(minY, c.y - 1)
    maxY = max(maxY, c.y + 1)
    minZ = min(minZ, c.z - 1)
    maxZ = max(maxZ, c.z + 1)

  var cnt = 0
  proc neighbors(pos: Coord3): iterator: Coord3 =
    return iterator(): Coord3 =
      for pos2 in pos.adj:
        if pos2.x notin minX..maxX or pos2.y notin minY..maxY or pos2.z notin minZ..maxZ:
          continue
        if pos2 notin space:
          yield pos2
        else:
          cnt += 1
  for _ in bfsM([(minX, minY, minZ), (maxX, maxY, maxZ)], neighbors):
    discard
  cnt
