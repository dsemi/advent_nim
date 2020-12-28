import sequtils
import strutils

proc parse(input: string): seq[int64] =
  input.splitlines.mapIt(it.parseBiggestInt)

proc anySumTo(ns: seq[int64], n: int64): bool =
  for i in ns.low .. ns.high:
    for j in i+1 .. ns.high:
      if ns[i] + ns[j] == n:
        return true
  false

proc findFirstInvalid(ns: seq[int64]): int64 =
  var n = 25
  while true:
    let slice = ns[n-25 ..< n]
    if not anySumTo(slice, ns[n]):
      return ns[n]
    n += 1

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
