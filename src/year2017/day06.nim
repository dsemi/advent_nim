import sequtils
import strutils
import tables

proc redistributeUntilCycle(input: string): (int, int) =
  var ns = input.splitWhitespace.map(parseInt)
  var m: Table[seq[int], int]
  for c in 0..int.high:
    if ns in m:
      return (c, c - m[ns])
    m[ns] = c
    let j = ns.maxIndex
    let val = ns[j]
    ns[j] = 0
    for k in j+1..j+val:
      inc ns[k mod ns.len]

proc part1*(input: string): int =
  input.redistributeUntilCycle[0]

proc part2*(input: string): int =
  input.redistributeUntilCycle[1]
