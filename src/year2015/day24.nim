import math
import sequtils
import strutils

import "../utils.nim"

proc quantumEntanglement(n: int, input: string): int =
  let wts = input.split.map(parseInt)
  let groupSize = wts.sum div n
  for i in 1 .. int.high:
    var qes: seq[int]
    for buf in combos(wts, i):
      if buf.sum == groupSize:
        qes.add(buf.prod)
    if qes.len > 0:
      return qes.min

proc part1*(input: string): int =
  quantumEntanglement(3, input)

proc part2*(input: string): int =
  quantumEntanglement(4, input)
