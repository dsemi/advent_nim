import math
import sequtils
import strutils
import itertools

iterator allCombinationsTotaling(n: int, xs: seq[int]): seq[seq[int]] =
  for i in 1 .. xs.len:
    var res = newSeq[seq[int]]()
    for combo in combinations(xs, i):
      if combo.sum == n:
        res.add(combo)
    yield res

proc part1*(input: string): int =
  for cs in allCombinationsTotaling(150, input.splitlines.map(parseInt)):
    result += cs.len

proc part2*(input: string): int =
  for cs in allCombinationsTotaling(150, input.splitlines.map(parseInt)):
    if cs.len > 0:
      return cs.len
