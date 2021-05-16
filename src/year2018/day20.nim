import sequtils
import tables

import "../utils"

let dir = {
  'N': ( 0, -1),
  'E': ( 1,  0),
  'S': ( 0,  1),
  'W': (-1,  0),
}.toTable

proc parseEdges(input: string): CountTable[Coord] =
  var stack: seq[Coord]
  var pos: Coord
  for c in input[1..^2]:
    case c:
      of '(': stack.add(pos)
      of ')': pos = stack.pop
      of '|': pos = stack[^1]
      else:
        let pos2 = pos + dir[c]
        if pos2 in result:
          result[pos2] = min(result[pos2], result[pos]+1)
        else:
          result[pos2] = result[pos]+1
        pos = pos2

proc part1*(input: string): int =
  toSeq(input.parseEdges.values).max

proc part2*(input: string): int =
  for v in input.parseEdges.values:
    if v >= 1000:
      inc result
