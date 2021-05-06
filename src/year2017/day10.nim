import sequtils
import strutils

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

proc part1*(input: string): int =
  let res = hash(1, input.split(',').map(parseInt))
  res[0] * res[1]

proc part2*(input: string): string =
  let res = hash(64, input.mapIt(it.ord) & @[17, 31, 73, 47, 23])
  res.distribute(16).mapIt(it.foldl(a xor b).toHex(2).toLower).join
