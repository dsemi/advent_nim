import math
import strformat
import strutils

proc bits(s: string): iterator(): int =
  return iterator(): int =
    for c in s:
      let n = fromHex[int]($c)
      yield n shr 3 and 1
      yield n shr 2 and 1
      yield n shr 1 and 1
      yield n and 1

proc num(bs: iterator(): int, n: int): int =
  for _ in 1..n:
    result = result shl 1 or bs()

proc packet(bs: iterator(): int, vsum: var int): int =
  vsum += bs.num(3)
  if bs.finished:
    return -1
  let typeId = bs.num(3)
  if typeId == 4:
    var n = 0
    while bs.num(1) == 1:
      n = n shl 4 or bs.num(4)
    return n shl 4 or bs.num(4)
  var ns: seq[int]
  if bs.num(1) == 0:
    let r = iterator(): int =
              for _ in 1..bs.num(15):
                yield bs()
    while not finished(r):
      let p = packet(r, vsum)
      if p != -1:
        ns.add(p)
  else:
    for _ in 1..bs.num(11):
      ns.add(packet(bs, vsum))
  case typeId
  of 0: ns.sum
  of 1: ns.prod
  of 2: ns.min
  of 3: ns.max
  of 5: int(ns[0] > ns[1])
  of 6: int(ns[0] < ns[1])
  of 7: int(ns[0] == ns[1])
  else: raiseAssert fmt"Bad type id: {typeId}"

proc part1*(input: string): int =
  discard packet(input.bits, result)

proc part2*(input: string): int =
  packet(input.bits, result)
