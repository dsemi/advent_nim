import fusion/matching
import sequtils
import strutils
import tables

proc parse(input: string): (seq[seq[int]], seq[bool]) =
  var m = initTable[string, int]()
  m["start"] = 0
  m["end"] = 1
  var v = @[newSeq[int](), newSeq[int]()]
  var l = @[true, true]
  for line in input.splitlines:
    [@a, @b] := line.split('-', 1)
    if a notin m:
      v.add(@[])
      l.add(a.all(isLowerAscii))
      m[a] = v.len - 1
    if b notin m:
      v.add(@[])
      l.add(b.all(isLowerAscii))
      m[b] = v.len - 1
    let ai = m[a]
    let bi = m[b]
    v[ai].add(bi)
    v[bi].add(ai)
  (v, l)

proc dfs(vis: var seq[int], l: seq[bool], m: seq[seq[int]], k: int, double: bool): int =
  var double = double
  if k == 1:
    return 1
  elif l[k] and vis[k] > 0:
    if double or k == 0:
      return 0
    double = true
  vis[k] += 1
  for child in m[k]:
    result += dfs(vis, l, m, child, double)
  vis[k] -= 1

proc part1*(input: string): int =
  let (v, l) = parse(input)
  var x = newSeq[int](v.len)
  dfs(x, l, v, 0, true)

proc part2*(input: string): int =
  let (v, l) = parse(input)
  var x = newSeq[int](v.len)
  dfs(x, l, v, 0, false)
