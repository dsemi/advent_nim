import sequtils
import strscans
import strutils

import "../utils"

type Nanobot = object
  pos: Coord3
  radius: int

proc parseNanobots(input: string): seq[Nanobot] =
  for line in input.splitLines:
    var x, y, z, r: int
    doAssert line.scanf("pos=<$i,$i,$i>, r=$i", x, y, z, r)
    result.add(Nanobot(pos: (x, y, z), radius: r))

proc inRange(pos: Coord3, bot: Nanobot): bool =
  (pos - bot.pos).abs.sum <= bot.radius

proc part1*(input: string): int =
  let ns = input.parseNanobots
  let maxBot = ns.foldl(if b.radius > a.radius: b else: a)
  for bot in ns:
    result += bot.pos.inRange(maxBot).int

type Cube = object
  lo, hi: Coord3

proc children(c: Cube): seq[Cube] =
  let mid = (c.lo + c.hi) div 2
  @[
    Cube(lo: (c.lo[0], c.lo[1], c.lo[2]), hi: (mid[0], mid[1], mid[2])),
    Cube(lo: (c.lo[0], c.lo[1], mid[2] + 1), hi: (mid[0], mid[1], c.hi[2])),
    Cube(lo: (c.lo[0], mid[1] + 1, c.lo[2]), hi: (mid[0], c.hi[1], mid[2])),
    Cube(lo: (c.lo[0], mid[1] + 1, mid[2] + 1), hi: (mid[0], c.hi[1], c.hi[2])),
    Cube(lo: (mid[0] + 1, c.lo[1], c.lo[2]), hi: (c.hi[0], mid[1], mid[2])),
    Cube(lo: (mid[0] + 1, c.lo[1], mid[2] + 1), hi: (c.hi[0], mid[1], c.hi[2])),
    Cube(lo: (mid[0] + 1, mid[1] + 1, c.lo[2]), hi: (c.hi[0], c.hi[1], mid[2])),
    Cube(lo: (mid[0] + 1, mid[1] + 1, mid[2] + 1), hi: (c.hi[0], c.hi[1], c.hi[2])),
  ]

proc inRange(c: Cube, n: Nanobot): bool =
  let p = (
    max(c.lo[0], min(c.hi[0], n.pos[0])),
    max(c.lo[1], min(c.hi[1], n.pos[1])),
    max(c.lo[2], min(c.hi[2], n.pos[2])),
  )
  p.inRange(n)


proc part2*(input: string): int =
  let ns = input.parseNanobots
  var cube = Cube(lo: (int.high, int.high, int.high), hi: (int.low, int.low, int.low))
  for n in ns:
    cube.lo = (min(cube.lo[0], n.pos[0]-n.radius),
               min(cube.lo[1], n.pos[1]-n.radius),
               min(cube.lo[2], n.pos[2]-n.radius))
    cube.hi = (max(cube.hi[0], n.pos[0]+n.radius),
               max(cube.hi[1], n.pos[1]+n.radius),
               max(cube.hi[2], n.pos[2]+n.radius))
  while cube.lo[0] < cube.hi[0] or cube.lo[1] < cube.hi[1] or cube.lo[2] < cube.hi[2]:
    let children = cube.children
    var i, m: int
    for j, c in children:
      let bots = ns.countIt(c.inRange(it))
      if bots > m:
        i = j
        m = bots
    cube = children[i]
  cube.lo.abs.sum
