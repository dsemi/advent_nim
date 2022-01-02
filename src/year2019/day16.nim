import itertools
import sequtils
import strutils
import sugar

iterator pattern(n: int): int =
  var skipped = false
  for x in cycle([0, 1, 0, -1]):
    for _ in 1..n:
      if skipped:
        yield x
      else:
        skipped = true

proc part1*(input: string): string =
  var ns = input.mapIt(($it).parseInt)
  for _ in 1..100:
    for (i, n) in ns.mpairs:
      var j, t = 0
      for x in pattern(i+1):
        t += ns[j] * x
        inc j
        if j > ns.high:
          break
      n = t.abs mod 10
  ns[0..7].mapIt($it).join

proc part2*(input: string): string =
  let offset = input[0..6].parseInt
  let ns = input.mapIt(($it).parseInt)
  var ds = collect(newSeq):
    for _ in 1..10000:
      for n in ns:
        n
  doAssert offset > ds.len div 2, "Offset is not large enough"
  ds = ds[offset..^1]
  for _ in 1..100:
    for i in countdown(ds.high, ds.low+1):
      ds[i-1] += ds[i]
      ds[i] = ds[i] mod 10
    ds[0] = ds[0] mod 10
  ds[0..7].mapIt($it).join
