import bitops
import deques
import sets
import sequtils
import strutils
import sugar

import "../utils"

const target = (31, 39)

proc neighbors(n: int, pos: Coord): iterator: Coord =
  return iterator(): Coord =
    for dir in [(1, 0), (-1, 0), (0, 1), (0, -1)]:
      let pos = pos + dir
      if pos.x >= 0 and pos.y >= 0:
        let x = pos.x
        let y = pos.y
        if (x*x + 3*x + 2*x*y + y + y*y + n).popcount mod 2 == 0:
          yield pos

proc part1*(input: string): int =
  let n = input.parseInt
  for (d, pos) in bfs((1, 1), (p) => neighbors(n, p)):
    if pos == target:
      return d

proc part2*(input: string): int =
  let n = input.parseInt
  for (d, pos) in bfs((1, 1), (p) => neighbors(n, p)):
    if d > 50:
      break
    inc result
