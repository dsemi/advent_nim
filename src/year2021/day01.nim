import sequtils
import strutils

proc solve(input: string, offset: int): int =
  let ns = input.splitlines.map(parseInt)
  for (a, b) in ns.zip(ns[offset..^1]):
    if a < b:
      inc result

proc part1*(input: string): int =
  solve(input, 1)

proc part2*(input: string): int =
  solve(input, 3)

