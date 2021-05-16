import sequtils
import strutils
import unpack

type Coord4 = tuple
  w: int
  x: int
  y: int
  z: int

proc parsePoints(input: string): seq[Coord4] =
  for line in input.splitLines:
    [a, b, c, d] <- line.split(',').map(parseInt)
    result.add((a, b, c, d))

proc dist(a, b: Coord4): int =
  abs(a.w - b.w) + abs(a.x - b.x) + abs(a.y - b.y) + abs(a.z - b.z)

proc constellations(pts: seq[Coord4]): seq[seq[Coord4]] =
  if pts.len == 0:
    return @[]
  var neighbs = pts[0..0]
  var rest = pts[1..^1]
  var changed = true
  while changed:
    changed = false
    var rest2: seq[Coord4]
    for p in rest:
      if neighbs.anyIt(it.dist(p) <= 3):
        changed = true
        neighbs.add(p)
      else:
        rest2.add(p)
    rest = rest2
  result = @[neighbs]
  result.add(constellations(rest))

proc part1*(input: string): int =
  input.parsePoints.constellations.len

proc part2*(input: string): string =
  " "
