import fusion/matching
import sequtils
import strutils
import sugar

proc consecutiveRuns(s: string): seq[int] =
  var c = 1
  for i in s.low..<s.high:
    if s[i] == s[i+1]:
      inc c
    else:
      result.add(c)
      c = 1
  result.add(c)

proc numValid(input: string, f: (string) -> bool): int =
  [@a, @b] := input.split('-').map(parseInt)
  for v in a..b:
    let s = $v
    if s.zip(s[1..^1]).allIt(it[0] <= it[1]) and f(s):
      inc result

proc part1*(input: string): int =
  input.numValid((s) => s.consecutiveRuns.anyIt(it >= 2))

proc part2*(input: string): int =
  input.numValid((s) => s.consecutiveRuns.anyIt(it == 2))
