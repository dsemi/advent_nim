import algorithm
import fusion/matching
import math
import sequtils
import strutils

type IpFilter = tuple
  lo: int
  hi: int

iterator parseIpFilters(input: string): IpFilter =
  var ips: seq[IpFilter]
  for line in input.splitLines:
    [@a, @b] := line.split('-').map(parseInt)
    ips.add((a, b))
  ips.sort
  var curr = ips[0]
  for next in ips[1..^1]:
    if next.lo <= curr.hi + 1:
      curr.hi = max(curr.hi, next.hi)
    else:
      yield curr
      curr = next
  yield curr

proc part1*(input: string): int =
  for (a, b) in parseIpFilters(input):
    if a > 0: return 0
    else: return b+1

proc part2*(input: string): int =
  result = 2 ^ 32
  for (a, b) in parseIpFilters(input):
    result -= b - a + 1
