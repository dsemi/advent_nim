import algorithm
import sequtils
import strutils

proc seatIds(input: string): seq[int] =
  input.multiReplace(("F", "0"), ("B", "1"), ("L", "0"), ("R", "1"))
    .splitlines()
    .map(parseBinInt)

proc part1*(input: string): int =
  seatIds(input).max

proc part2*(input: string): int =
  let ids = seatIds(input).sorted
  for (a, b) in ids.zip(ids[1 .. ^1]):
    if a + 2 == b:
      return a + 1
