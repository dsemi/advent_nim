import fusion/matching
import std/math
import std/strutils
import std/sugar

func idx(name: string): uint16 =
  676 * uint16(name[0].ord - 'A'.ord) +
  26 * uint16(name[1].ord - 'A'.ord) +
  uint16(name[2].ord - 'A'.ord)

proc network(input: string, isStart: (uint16) -> bool): array[3, seq[uint16]] =
  var starts = newSeq[uint16]()
  var lefts = newSeq[uint16](26*26*26)
  var rights = newSeq[uint16](26*26*26)
  for line in input.splitLines:
    let k = idx(line[0 ..< 3])
    if isStart(k):
      starts.add k
    let l = idx(line[7 ..< 10])
    lefts[k] = l
    let r = idx(line[12 ..< 15])
    rights[k] = r
  [starts, lefts, rights]

proc solve(input: string, isStart, isEnd: (uint16) -> bool): int =
  [@dirs, @rest] := input.split("\n\n")
  [@starts, @lefts, @rights] := rest.network(isStart)
  result = 1
  for start in starts:
    var node = start
    for i in 0 .. int.high:
      if isEnd(node):
        result = lcm(result, i)
        break
      node = if dirs[i mod dirs.len] == 'L': lefts[node] else: rights[node]

const AAA = idx("AAA")
const ZZZ = idx("ZZZ")

proc part1*(input: string): int =
  input.solve((s) => s == AAA, (s) => s == ZZZ)

proc part2*(input: string): int =
  input.solve((s) => s mod 26 == 0, (s) => s mod 26 == 25)
