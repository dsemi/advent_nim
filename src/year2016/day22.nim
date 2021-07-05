import deques
import sequtils
import sets
import strscans
import strutils
import tables

import "../utils"

type Node = tuple
  coord: Coord
  used: int
  avail: int

proc parseNode(line: string): Node =
  var x, y, size, used, avail, usedp: int
  doAssert line.scanf("/dev/grid/node-x$i-y$i$s$iT$s$iT$s$iT$s$i%",
                      x, y, size, used, avail, usedp)
  (coord: (x, y), used: used, avail: avail)

proc part1*(input: string): int =
  let nodes = input.splitLines[2..^1].map(parseNode)
  for i in nodes.low..nodes.high:
    for j in i+1..nodes.high:
      if nodes[i].used > 0 and nodes[i].used < nodes[j].avail or
         nodes[j].used > 0 and nodes[j].used < nodes[i].avail:
        inc result

proc part2*(input: string): int =
  let nodes = input.splitLines[2..^1].map(parseNode)
  var grid: Table[Coord, Node]
  var opn = (0, 0)
  var mx = (0, 0)
  for node in nodes:
    grid[node.coord] = node
    if node.used == 0:
      opn = node.coord
    mx = max(mx, node.coord)

  proc neighbors(st: (Coord, Coord)): iterator: (Coord, Coord) =
    return iterator(): (Coord, Coord) =
      let (o, t) = st
      for d in [(0, 1), (0, -1), (1, 0), (-1, 0)]:
        let o2 = o + d
        if o2 in grid and grid[o2].used <= 100:
          let next = (o2, if o2 == t: o else: t)
          yield next

  for (d, v) in bfs((opn, (mx[0], 0)), neighbors):
    if v[1] == (0, 0):
      return d
