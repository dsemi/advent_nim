import sets
import strutils

import "../utils"

proc simRope(input: string, ropeLen: int): int =
  var knots = newSeq[Coord](ropeLen)
  var tailPos = initHashSet[Coord]()
  tailPos.incl(knots[^1])
  for line in input.splitLines:
    let pts = line.split
    for _ in 1..pts[1].parseInt:
      case pts[0][0]
      of 'L': knots[0].x -= 1
      of 'R': knots[0].x += 1
      of 'U': knots[0].y += 1
      of 'D': knots[0].y -= 1
      else: raiseAssert "impossible"
      for i in 1..knots.high:
        let diff = knots[i-1] - knots[i]
        if diff.x.abs > 1 or diff.y.abs > 1:
          knots[i] += diff.sgn
      tailPos.incl(knots[^1])
  tailPos.len

proc part1*(input: string): int =
  input.simRope(2)

proc part2*(input: string): int =
  input.simRope(10)
