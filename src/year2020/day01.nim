import math
import sequtils
import strutils

import "../utils.nim"

proc solve(n: int, input: string): int =
  let ns = input.splitlines.map(parseInt)
  for buf in combos(ns, n):
    if buf.sum == 2020:
      return buf.prod

proc part1*(input: string): int =
  solve(2, input)

proc part2*(input: string): int =
  solve(3, input)
