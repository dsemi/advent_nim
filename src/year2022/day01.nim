import algorithm
import math
import sequtils
import strutils

iterator elves(input: string): int =
  for elf in input.split("\n\n"):
    yield elf.splitLines.map(parseInt).sum

proc part1*(input: string): int =
  for elf in input.elves:
    result = max(result, elf)

proc part2*(input: string): int =
  var elves = toSeq(input.elves)
  elves.sort(order = Descending)
  elves[0..2].sum
