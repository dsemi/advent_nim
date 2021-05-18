import algorithm
import fusion/matching
import sequtils
import sets
import strutils
import sugar
import tables

import "../utils"

iterator parseOrbits(input: string): (string, string) =
  for line in input.splitLines:
    [@a, @b] := line.split(')')
    yield (a, b)

proc part1*(input: string): int =
  var t: Table[string, seq[string]]
  for (k, v) in input.parseOrbits:
    t.mgetOrPut(k, @[]).add(v)
  for (d, s) in dfs("COM", (n) => t.getOrDefault(n, @[])):
    result += d

proc part2*(input: string): int =
  let t = collect(initTable):
    for (v, k) in input.parseOrbits:
      {k: v}
  proc pathFromCom(k: string): seq[string] =
    var k = k
    while k in t:
      k = t[k]
      result.add(k)
    result.reverse
  let xs = "YOU".pathFromCom
  let ys = "SAN".pathFromCom
  for i, (x, y) in xs.zip(ys):
    if x != y:
      return xs.len + ys.len - 2 * i
