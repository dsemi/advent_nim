import algorithm
import math
import sequtils
import strutils
import tables

proc parse(input: string): seq[int] =
  result = input.splitlines.mapIt(it.parseInt).sorted
  result.insert(0, 0)
  result.add(result[^1] + 3)

proc part1*(input: string): int =
  let ns = parse(input)
  var cnt = initCountTable[int]()
  for (a, b) in ns.zip(ns[1 .. ^1]):
    cnt.inc(b - a)
  cnt[1] * cnt[3]

proc part2*(input: string): int =
  let ns = parse(input)
  var dp = repeat(0, ns[^1]+1)
  dp[0] = 1
  for n in ns[1 .. ^1]:
    dp[n] = [n-1, n-2, n-3].filterIt(it >= 0).mapIt(dp[it]).sum()
  dp[ns[^1]]
