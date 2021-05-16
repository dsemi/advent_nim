import fusion/matching
import math
import re
import sequtils
import strutils
import sugar

import "../utils"

proc parse(input: string): seq[seq[int]] =
  for line in input.splitlines:
    [@speed, @flyTime, @restTime] := line.findAll(re"\d+").map(parseInt)
    let period = repeat(speed, flyTime) & repeat(0, restTime)
    let full = collect(newSeq):
      for i in 0 ..< 2503:
        period[i mod period.len]
    result.add(full.cumsummed)

proc part1*(input: string): int =
  parse(input).mapIt(it[^1]).max

proc part2*(input: string): int =
  var x = transpose(parse(input))
  for row in x.mitems:
    let m = row.max
    for v in row.mitems:
      v = if v == m: 1 else: 0
  x.foldl(a.zip(b).mapIt(it[0] + it[1])).max
