import sequtils
import strutils
import tables

proc part1*(input: string): int =
  let counts = input.splitLines.mapIt(it.toCountTable)
  var(twos, threes) = (0, 0)
  for tbl in counts:
    let cnts = toSeq(tbl.values)
    if cnts.anyIt(it == 2): inc twos
    if cnts.anyIt(it == 3): inc threes
  twos * threes

proc part2*(input: string): string =
  let ids = input.splitLines
  for i, b1 in ids:
    for j in i+1 .. ids.high:
      let b2 = ids[j]
      var diff = 0
      for (a, b) in b1.zip(b2):
        if a != b:
          inc diff
      if diff == 1:
        return b1.zip(b2).filterIt(it[0] == it[1]).mapIt(it[0]).join
