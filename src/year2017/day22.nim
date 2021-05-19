import sequtils
import strutils
import sugar

import "../utils"

type NodeState = enum
  Cleaned, Weakened, Infected, Flagged

const
  left = (0, 1)
  right = (0, -1)

proc turn(d: var Coord, v: NodeState) =
  case v:
    of Cleaned:  d *= left
    of Weakened: discard
    of Infected: d *= right
    of Flagged:  d *= right*right

proc countInfections(bursts: int, next: (NodeState) -> NodeState, input: string): int =
  var grid = newSeq[seq[NodeState]](10001)
  for i in grid.low..grid.high:
    grid[i] = newSeq[NodeState](10001)
  for (row, r) in toSeq(input.splitLines).zip(toSeq(4988..5012)):
    for (v, c) in row.zip(toSeq(4988..5012)):
      if v == '#':
        grid[r][c] = Infected
  var pos = (5000, 5000)
  var dir = (-1, 0)
  for _ in 1..bursts:
    let val = grid[pos[0]][pos[1]]
    dir.turn(val)
    let val2 = val.next
    result += int(val2 == Infected)
    grid[pos[0]][pos[1]] = val2
    pos += dir

proc part1*(input: string): int =
  let f = (v: NodeState) => (case v:
                               of Cleaned: Infected
                               of Infected: Cleaned
                               else: raiseAssert "InvalidState")
  countInfections(10_000, f, input)

proc part2*(input: string): int =
  let f = (v: NodeState) => (case v:
                               of Cleaned: Weakened
                               of Weakened: Infected
                               of Infected: Flagged
                               of Flagged: Cleaned)
  countInfections(10_000_000, f, input)
