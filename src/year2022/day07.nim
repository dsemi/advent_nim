import std/algorithm
import std/math
import std/strutils

proc allSizes(input: string): seq[int] =
  var fstree = newSeq[int]()
  for line in input.splitLines:
    if line.startsWith("$ cd "):
      if line.endsWith(".."):
        fstree[^2] += fstree[^1]
        result.add fstree.pop
      else:
        fstree.add(0)
    elif line.find({'0'..'9'}) == 0:
      fstree[^1] += line.split[0].parseInt
  result.add fstree.reversed.cumsummed

proc part1*(input: string): int =
  for size in input.allSizes:
    if size <= 100000:
      result += size

proc part2*(input: string): int =
  let sizes = input.allSizes
  let target = sizes[^1] - 40000000
  result = int.high
  for size in sizes:
    if size >= target:
      result = min(result, size)
