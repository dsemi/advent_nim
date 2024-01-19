import fusion/matching
import std/math
import std/sequtils
import std/strutils

proc nums(i: string): seq[uint64] =
  i.splitWhitespace[1..^1].mapIt(it.parseInt.uint64)

proc race(time, dist: uint64): uint64 =
  # hold^2 - hold*time + dist = 0
  let root = (time * time - 4 * dist).float64.sqrt
  let start = (time.float64 - root) / 2
  let last = (time.float64 + root) / 2
  uint64(last.ceil - start.floor - 1)

proc part1*(input: string): uint64 =
  [@times, @dists] := input.splitLines.map(nums)
  result = 1
  for (time, winDist) in zip(times, dists):
    result *= race(time, winDist)

proc squish(i: string): uint64 =
  for c in i:
    if c in Digits:
      result = 10*result + uint64(c.ord - '0'.ord)

proc part2*(input: string): uint64 =
  [@time, @dist] := input.splitLines.map(squish)
  race(time, dist)
