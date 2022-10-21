import fusion/matching
import sequtils
import strutils

type Node = object
  pt: (int, int, int, int)
  parent: uint16
  rank: int

proc parsePoints(input: string): seq[Node] =
  for (i, line) in pairs(input.splitLines):
    [@a, @b, @c, @d] := line.split(',').map(parseInt)
    result.add(Node(pt: (a, b, c, d), parent: uint16(i)))

proc dist(a, b: Node): int =
  abs(a.pt[0] - b.pt[0]) + abs(a.pt[1] - b.pt[1]) + abs(a.pt[2] - b.pt[2]) + abs(a.pt[3] - b.pt[3])

proc find(points: seq[Node], k: uint16): uint16 =
  result = k
  while result != points[result].parent:
    result = points[result].parent

proc union(points: var seq[Node], x, y: uint16) =
  let xRoot = find(points, x)
  let yRoot = find(points, y)
  if xRoot == yRoot:
    return
  if points[xRoot].rank < points[yRoot].rank:
    points[xRoot].parent = yRoot
  elif points[xRoot].rank > points[yRoot].rank:
    points[yRoot].parent = xRoot
  else:
    points[yRoot].parent = xRoot
    points[xRoot].rank += 1

proc constellations(pts: var seq[Node]): int =
  for i in pts.low .. pts.high:
    for j in i+1 .. pts.high:
      if dist(pts[i], pts[j]) <= 3:
        union(pts, uint16(i), uint16(j))
  var s: set[uint16]
  for p in pts.low .. pts.high:
    s.incl(find(pts, uint16(p)))
  s.card

proc part1*(input: string): int =
  var pts = parsePoints(input)
  constellations(pts)

proc part2*(input: string): string =
  " "
