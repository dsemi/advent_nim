import math
import sequtils
import strutils

import "../utils"

iterator allCombos(xs: seq[int]): int =
  for i in 1 .. xs.len:
    var res: int
    for buf in combos(xs, i):
      if buf.sum == 150:
        inc res
    yield res

proc part1*(input: string): int =
  for n in allCombos(input.splitlines.map(parseInt)):
    result += n

proc part2*(input: string): int =
  for n in allCombos(input.splitlines.map(parseInt)):
    if n > 0:
      return n
