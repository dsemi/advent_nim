import algorithm
import fusion/matching
import sequtils
import strutils
import tables

iterator paths(input: string): int =
  var adj: seq[seq[int]]
  var m: Table[string, int]
  var cnt: int
  let lines = input.splitlines.len
  for l in 1 .. int.high:
    if l * (l + 1) div 2 == lines:
      for _ in 0 .. l:
        adj.add(newSeq[int](l + 1))
      break
  for line in input.splitlines:
    [@k1, _, @k2, _, @v] := line.split
    if not m.hasKeyOrPut(k1, cnt):
      inc cnt
    if not m.hasKeyOrPut(k2, cnt):
      inc cnt
    let n = v.parseInt
    adj[m[k1]][m[k2]] = n
    adj[m[k2]][m[k1]] = n
  var perm = toSeq(0 ..< adj.len)
  var run = true
  while run:
    var t = 0
    for i in perm.low .. perm.high-1:
      t += adj[perm[i]][perm[i+1]]
    yield t
    run = perm.nextPermutation

proc part1*(input: string): int =
  result = int.high
  for p in paths(input):
    result = min(result, p)

proc part2*(input: string): int =
  for p in paths(input):
    result = max(result, p)
