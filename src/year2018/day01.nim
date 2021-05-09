import math
import intsets
import sequtils
import strutils

proc part1*(input: string): int =
  input.splitLines.map(parseInt).sum

proc part2*(input: string): int =
  let ns = input.splitLines.map(parseInt)
  var x = 0
  var s: IntSet
  for i in 0..int.high:
    if x in s:
      return x
    s.incl(x)
    x += ns[i mod ns.len]
