import strutils
import tables
import unpack

type Map = Table[(char, char, char, char, char), char]

proc parse(input: string): (Map, seq[(int, char)]) =
  [initial, rest] <- input.split("\n\n")
  for i, c in initial.replace("initial state: "):
    result[1].add((i, c))
  for line in rest.splitLines:
    result[0][(line[0], line[1], line[2], line[3], line[4])] = line[^1]

proc nextGen(s: seq[(int, char)], m: Map): seq[(int, char)] =
  let (x0, x1) = (s[0][0], s[^1][0])
  let s = @[(x0-3, '.'), (x0-2, '.'), (x0-1, '.')] & s & @[(x1+1, '.'), (x1+2, '.'), (x1+3, '.')]
  for i in s.low..s.high-4:
    result.add((s[i+2][0], m[(s[i][1], s[i+1][1], s[i+2][1], s[i+3][1], s[i+4][1])]))

proc sumIndices(s: seq[(int, char)]): int =
  for (i, c) in s:
    if c == '#':
      result += i

proc part1*(input: string): int =
  var (m, start) = input.parse
  for _ in 1..20:
    start = start.nextGen(m)
  start.sumIndices

proc findArith(start: seq[(int, char)], m: Map): (int, int, int) =
  var prev = 0
  var x = start
  for c in 0..int.high:
    let x2 = x.nextGen(m)
    let prev2 = x2.sumIndices - x.sumIndices
    if prev2 == prev:
      return (c, prev, x.sumIndices)
    prev = prev2
    x = x2

proc part2*(input: string): int64 =
  let (m, start) = input.parse
  let (n, diff, tot) = start.findArith(m)
  (50_000_000_000 - n) * diff + tot
