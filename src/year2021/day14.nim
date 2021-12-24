import fusion/matching
import sequtils
import strutils
import tables
import sugar

proc polymerize(input: string, n: int): int =
  [@tmpl, @rest] := input.split("\n\n", 1)
  let d = collect(initTable):
    for line in rest.splitlines:
      let pts = line.split(" -> ", 1)
      {pts[0]: pts[1][0]}
  var cnts = initTable[string, int]()
  for i in 0..tmpl.len-2:
    cnts.mgetOrPut(tmpl[i..i+1], 0).inc
  for _ in 1..n:
    var cnts2 = initTable[string, int]()
    for k, v in cnts.pairs:
      let rep = d[k]
      cnts2.mGetOrPut(k[0] & rep, 0).inc(v)
      cnts2.mGetOrPut(rep & k[1], 0).inc(v)
    cnts = cnts2
  var lets = initTable[char, int]()
  for k, v in cnts.pairs:
    lets.mgetOrPut(k[0], 0).inc(v)
  lets.mgetOrPut(tmpl[^1], 0).inc
  lets.values.toSeq.max - lets.values.toSeq.min

proc part1*(input: string): int =
  polymerize(input, 10)

proc part2*(input: string): int =
  polymerize(input, 40)
