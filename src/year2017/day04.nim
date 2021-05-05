import algorithm
import sequtils
import strutils

proc part1*(input: string): int =
  for line in input.splitLines:
    let ps = line.splitWhitespace
    if ps.len == ps.deduplicate.len:
      inc result

proc part2*(input: string): int =
  for line in input.splitLines:
    let ps = line.splitWhitespace.mapIt(it.sorted)
    if ps.len == ps.deduplicate.len:
      inc result
