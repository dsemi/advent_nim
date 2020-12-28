import itertools
import math
import sequtils
import strutils

proc solve(n: int, input: string): int =
  let ns = input.splitlines.map(parseInt)
  for combo in combinations(ns, n):
    if combo.sum == 2020:
      return combo.prod

proc part1*(input: string): int =
  solve(2, input)

proc part2*(input: string): int =
  solve(3, input)
