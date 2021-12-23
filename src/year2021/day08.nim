import fusion/matching
import math
import sequtils
import strutils
import sugar
import tables

const FREQS = [42, 17, 34, 39, 30, 37, 41, 25, 49, 45]

iterator parse(input: string): seq[int] =
  for line in input.splitlines:
    [@key, @ns] := line.split(" | ", 1)
    let hist = key.replace(" ", "").toCountTable
    yield collect(newSeq):
      for n in ns.splitWhitespace:
        FREQS.find(n.mapIt(hist[it]).sum)


proc part1*(input: string): int =
  for ns in parse(input):
    for n in ns:
      if n in [1, 4, 7, 8]:
        inc result

proc part2*(input: string): int =
  for ns in parse(input):
    result += ns.foldl(a * 10 + b)
