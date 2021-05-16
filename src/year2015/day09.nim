import fusion/matching
import itertools
import sequtils
import strutils
import tables

iterator paths(input: string): int =
  var d = initTable[string, Table[string, int]]()
  for line in input.splitlines:
    [@p1, _, @p2, _, @v] := line.split
    let n = v.parseInt
    d.mGetOrPut(p1, initTable[string, int]())[p2] = n
    d.mGetOrPut(p2, initTable[string, int]())[p1] = n
  for perm in permutations(toSeq(d.keys)):
    var t = 0
    for i in perm.low .. perm.high-1:
      t += d[perm[i]][perm[i+1]]
    yield t

proc part1*(input: string): int =
  result = int.high
  for p in paths(input):
    result = min(result, p)

proc part2*(input: string): int =
  for p in paths(input):
    result = max(result, p)
