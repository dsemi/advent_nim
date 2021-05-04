import deques
import re
import sequtils
import sets
import strutils
import sugar
import tables
import unpack

import "../utils"

let reg = re"/dev/grid/node-x(\d+)-y(\d+)\s+(\d+)T\s+(\d+)T\s+(\d+)T\s+(\d+)%"

type Node = tuple
  coord: Coord
  used: int
  avail: int

proc parseNode(line: string): Node =
  var cap: array[6, string]
  doAssert match(line, reg, cap), line
  [x, y, _, used, avail, _] <- cap.map(parseInt)
  (coord: (x, y), used: used, avail: avail)

proc part1*(input: string): int =
  let nodes = input.splitLines[2..^1].map(parseNode)
  for i in nodes.low..nodes.high:
    for j in i+1..nodes.high:
      if nodes[i].used > 0 and nodes[i].used < nodes[j].avail or
         nodes[j].used > 0 and nodes[j].used < nodes[i].avail:
        inc result

proc neighbors(grid: Table[Coord, Node], st: (Coord, Coord)): iterator: (Coord, Coord) =
  return iterator(): (Coord, Coord) =
    let (o, t) = st
    for d in [(0, 1), (0, -1), (1, 0), (-1, 0)]:
      let o2 = o + d
      if o2 in grid and grid[o2].used <= 100:
        let next = (o2, if o2 == t: o else: t)
        yield next

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
  for (d, node) in bfs((opn, (mx[0], 0)), (st) => neighbors(grid, st)):
    if node[1] == (0, 0):
      return d
