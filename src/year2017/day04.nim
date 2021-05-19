import algorithm
import sequtils
import strutils

proc part1*(input: string): int =
  for line in input.splitLines:
    let ps = line.splitWhitespace
    result += int(ps.len == ps.deduplicate.len)

proc part2*(input: string): int =
  for line in input.splitLines:
    let ps = line.splitWhitespace.mapIt(it.sorted)
    result += int(ps.len == ps.deduplicate.len)
