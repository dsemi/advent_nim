import math
import sequtils
import strutils

import "../utils"

proc valid(sides: openArray[int]): bool =
  sides.max < sides.sum - sides.max

proc part1*(input: string): int =
  for line in input.splitLines:
    let ns = line.splitWhitespace.map(parseInt)
    if ns.valid:
      inc result

proc part2*(input: string): int =
  let grid = input.splitLines.mapIt(it.splitWhitespace.map(parseInt)).transpose
  for row in grid:
    for i in countup(row.low, row.high, 3):
      if row[i..i+2].valid:
        inc result
