import bitops
import sequtils
import sets

import "../utils"

proc reverse[T](v: var openArray[T], lo: int, hi: int) =
  var lo = lo
  var hi = hi
  while lo < hi:
    (v[lo mod v.len], v[hi mod v.len]) = (v[hi mod v.len], v[lo mod v.len])
    inc lo
    dec hi

proc hash(n: int, lens: openArray[int]): seq[int] =
  for i in 0..255:
    result.add(i)
  var pos = 0
  var skipSize = 0
  for _ in 1..n:
    for l in lens:
      result.reverse(pos, pos+l-1)
      pos += l + skipSize
      inc skipSize

proc knotHash(s: string): seq[int] =
  let res = hash(64, s.mapIt(it.ord) & @[17, 31, 73, 47, 23])
  res.distribute(16).mapIt(it.foldl(a xor b))

proc hashes(key: string): seq[seq[int]] =
  for i in 0..127:
    result.add(knotHash(key & "-" & $i))

proc part1*(input: string): int =
  for h in hashes(input):
    result += h.foldl(a + b.popcount, 0)

proc grid(bss: seq[seq[int]]): HashSet[Coord] =
  for r, bs in bss:
    for c, w in bs:
      for i in 0..7:
        if w.testBit(i):
          result.incl((r, c*8 + 7 - i))

proc adjacents(c: Coord): seq[Coord] =
  for d in [(1, 0), (-1, 0), (0, 1), (0, -1)]:
    let c2 = c + d
    if c2[0] >= 0 and c2[0] < 128 and c2[1] >= 0 and c2[1] < 128:
      result.add(c2)

proc regionContaining(arr: HashSet[Coord], c: Coord): HashSet[Coord] =
  var xs = @[c]
  while xs.len > 0:
    let x = xs.pop
    if x notin arr or x in result:
      continue
    result.incl(x)
    xs.add(adjacents(x))

proc part2*(input: string): int =
  let arr = grid(hashes(input))
  var s: HashSet[Coord]
  for r in 0..127:
    for c in 0..127:
      let x = (r, c)
      if x notin arr or x in s:
        continue
      inc result
      s.incl(regionContaining(arr, x))
