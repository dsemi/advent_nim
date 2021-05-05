import sequtils
import strutils

proc part1*(input: string): int =
  for line in input.splitLines:
    let ns = line.splitWhitespace.map(parseInt)
    result += ns.max - ns.min

proc part2*(input: string): int =
  for line in input.splitLines:
    let ns = line.splitWhitespace.map(parseInt)
    block outer:
      for x in ns:
        for y in ns:
          if x != y and x mod y == 0:
            result += x div y
            break outer
