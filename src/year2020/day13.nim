import fusion/matching
import sequtils
import strutils
import sugar

import "../utils"

proc parse(input: string): (int, seq[(int, int)]) =
  [@t, @row] := input.splitlines
  let buses = collect(newSeq):
    for i, x in toSeq(row.split(',')):
      if x != "x":
        (-i, x.parseInt)
  (t.parseInt, buses)

proc min(a: (int, int), b: (int, int)): (int, int) =
  if a[1] <= b[1]: a else: b

proc part1*(input: string): int =
  let (t, buses) = parse(input)
  let (id, time) = buses.mapIt((it[1], it[1] - t mod it[1])).foldl(min(a, b))
  id * time

proc part2*(input: string): int =
  chineseRemainder(parse(input)[1])
