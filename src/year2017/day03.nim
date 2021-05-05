import strutils
import tables

import "../utils"

proc midPt(x, y: int): int =
  (x - y) div 2 + y

iterator corners(): int =
  var x = 1
  yield x
  for i in 1..int.high:
    x += i
    yield x
    x += i
    yield x

proc part1*(input: string): int =
  let n = input.parseInt
  var ns: seq[int]
  for c in corners():
    ns.add(c)
    if c >= n:
      break
  let a = ns[^1]
  let b = ns[^2]
  let c = ns[^3]
  b - midpt(b, c) + abs(n - midpt(a, b))

iterator spiralPath(): Coord =
  let dirs = [(1, 0), (0, 1), (-1, 0), (0, -1)]
  var c = 0
  var x = dirs[c]
  for i in 1..int.high:
    for _ in 1..i:
      yield x
    c = (c + 1) mod dirs.len
    x = dirs[c]
    for _ in 1..i:
      yield x
    c = (c + 1) mod dirs.len
    x = dirs[c]

proc sumAdj(m: var Table[Coord, int], pos: Coord): int =
  for x in [-1, 0, 1]:
    for y in [-1, 0, 1]:
      if x != 0 or y != 0:
        result += m.getOrDefault(pos + (x, y), 0)

iterator spiralInts(): int =
  var m = {(0, 0): 1}.toTable
  var pos = (0, 0)
  for d in spiralPath():
    pos += d
    let val = sumAdj(m, pos)
    yield val
    m[pos] = val

proc part2*(input: string): int =
  let n = input.parseInt
  for x in spiralInts():
    if x > n:
      return x
