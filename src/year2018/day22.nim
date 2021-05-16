import hashes
import sequtils
import strutils
import sugar

import "../utils"

type
  Tool = enum
    Neither, Torch, ClimbingGear

  Node = tuple
    pos: Coord
    tool: Tool

proc next(t: Tool): Tool {.inline.} =
  if t == ClimbingGear:
    return Neither
  t.succ

proc parse(input: string): (int, Coord) =
  let lns = input.splitLines
  result[0] = lns[0].split[^1].parseInt
  let pts = lns[1].split[^1].split(',').map(parseInt)
  result[1] = (pts[0], pts[1])

proc erosionLevels(depth: int, target: Coord): seq[seq[Tool]] =
  let mx = max(target[0], target[1]) + 3 # Arbitrary buffer size for search
  var arr = newSeqWith(mx + 1, newSeq[int](mx + 1))
  for x in 0..<mx:
    for y in 0..<mx:
      let geologicIndex = if (x, y) == target:
                            0
                          elif x == 0:
                            y * 48271
                          elif y == 0:
                            x * 16807
                          else:
                            arr[x-1][y] * arr[x][y-1]
      arr[x][y] = (geologicIndex + depth) mod 20183
  result = newSeqWith(mx + 1, newSeq[Tool](mx + 1))
  for x in 0..<mx:
    for y in 0..<mx:
      result[x][y] = Tool(arr[x][y] mod 3)

proc part1*(input: string): int =
  let (depth, target) = input.parse
  for x, row in erosionLevels(depth, target):
    for y, v in row:
      if x <= target[0] and y <= target[1]:
        result += v.ord

proc part2*(input: string): int =
  let (depth, target) = input.parse
  let els = erosionLevels(depth, target)

  proc neighbors(node: Node): iterator: Node =
    return iterator(): Node =
      for d in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
        let nNode: Node = (node.pos + d, node.tool)
        if nNode.pos[0] in els.low..els.high and
           nNode.pos[1] in els.low..els.high and
           nNode.tool != els[nNode.pos[0]][nNode.pos[1]]:
          yield nNode
      for t in [node.tool.next, node.tool.next.next]:
        let nNode: Node = (node.pos, t)
        if nNode.tool != els[nNode.pos[0]][nNode.pos[1]]:
          yield nNode

  proc heur(node: Node): int =
    sum(abs(target - node.pos))

  proc time(a, b: Node): int =
    if a[1] == b[1]: 1
    else: 7

  let path = aStar(neighbors, time, heur, (a) => a == (target, Torch), ((0, 0), Torch))
  for (a, b) in path.zip(path[1..^1]):
    result += time(a, b)
