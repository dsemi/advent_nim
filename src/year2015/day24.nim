import itertools
import math
import sequtils
import strutils

proc quantumEntanglement(n: int, input: string): int =
  let wts = input.split.map(parseInt)
  let groupSize = wts.sum div n
  for i in count(1):
    var qes: seq[int]
    for c in combinations(wts, i):
      if c.sum == groupSize:
        qes.add(c.prod)
    if qes.len > 0:
      return qes.min

proc part1*(input: string): int =
  quantumEntanglement(3, input)

proc part2*(input: string): int =
  quantumEntanglement(4, input)
