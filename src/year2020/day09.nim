import math
import sequtils
import strutils

import "../utils"

proc parse(input: string): seq[int64] =
  input.splitlines.map(parseBiggestInt)

proc findFirstInvalid(ns: seq[int64]): int64 =
  for n in 25 .. int.high:
    var any = false
    for buf in combos(ns[n-25 ..< n], 2):
      if buf.sum == ns[n]:
        any = true
        break
    if not any:
      return ns[n]

proc part1*(input: string): int64 =
  findFirstInvalid(parse(input))

proc part2*(input: string): int64 =
  let ns = parse(input)
  let n = findFirstInvalid(ns)
  var lo, hi = 0
  var acc: int64 = 0
  while acc != n:
    if acc < n:
      acc += ns[hi]
      hi += 1
    elif acc > n:
      acc -= ns[lo]
      lo += 1
  return ns[lo ..< hi].min + ns[lo ..< hi].max
