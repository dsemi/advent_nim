import sequtils
import strutils

proc solve(n: int, input: string): int =
  var m = repeat(-1, n+1)
  var i = 1
  for v in input.split(',').map(parseInt):
    m[v] = i
    i += 1
  result = 0
  for i in i ..< n:
    (m[result], result) = (i, if m[result] == -1: 0 else: i - m[result])

proc part1*(input: string): int =
  solve(2020, input)

proc part2*(input: string): int =
  solve(30_000_000, input)
