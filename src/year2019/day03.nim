import strutils

import "../utils"

type Orientation = enum
  V, H

type Segment = ref object
  o: Orientation
  a, b: Coord
  d: int
  r: bool

proc parseWires(input: string): seq[seq[Segment]] =
  for line in input.splitLines:
    var pos = (0, 0)
    var steps = 0
    result.add newSeq[Segment]()
    for p in line.split(','):
      let (o, d) = case p[0]:
                     of 'U': (V, (0, 1))
                     of 'D': (V, (0, -1))
                     of 'L': (H, (-1, 0))
                     of 'R': (H, (1, 0))
                     else: raiseAssert "Unknown direction: " & p
      let n = p[1..^1].parseInt
      let prev = pos
      pos += d.scale(n)
      let seg = if prev < pos: Segment(o: o, a: prev, b: pos, d: steps, r: false)
                else: Segment(o: o, a: pos, b: prev, d: steps + n, r: true)
      steps += n
      result[^1].add seg

iterator intersections(a, b: seq[Segment]): Coord =
  for w1 in a:
    for w2 in b:
      if w1.o == w2.o: continue
      let (hs, vs) = if w1.o == H: (w1, w2) else: (w2, w1)
      if vs.a.x in hs.a.x .. hs.b.x and hs.a.y in vs.a.y .. vs.b.y:
        let (hd, vd) = ((if hs.r: -1 else: 1), (if vs.r: -1 else: 1))
        yield (vs.a.x.abs + hs.a.y.abs, hs.d + hd*abs(hs.a.x - vs.a.x) + vs.d + vd*abs(vs.a.y - hs.a.y))

template solve(input: string, body: untyped) =
  let wires = input.parseWires
  result = int.high
  for w1 in wires.low .. wires.high:
    for w2 in w1+1 .. wires.high:
      for i in intersections(wires[w1], wires[w2]):
        let it {.inject.} = i
        result = min(result, body)

proc part1*(input: string): int =
  input.solve(it.x)

proc part2*(input: string): int =
  input.solve(it.y)
