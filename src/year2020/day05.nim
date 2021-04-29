import sequtils
import strutils

proc seatIds(input: string): seq[int] =
  input.multiReplace(("F", "0"), ("B", "1"), ("L", "0"), ("R", "1"))
    .splitlines()
    .map(parseBinInt)

proc part1*(input: string): int =
  seatIds(input).max

proc part2*(input: string): int =
  let ids = seatIds(input)
  var (mn, mx, tot) = (int.high, int.low, 0)
  for id in ids:
    mn = min(id, mn)
    mx = max(id, mx)
    tot += id
  return ((mn + mx) * (ids.len + 1) div 2) - tot
