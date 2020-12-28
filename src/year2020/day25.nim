import math
import sequtils
import strutils
import tables
import unpack

import "../utils"

proc part1*(input: string): int =
  let md = 20201227
  [card, door] <- input.splitlines.map(parseInt)
  let m = int(ceil(sqrt(float(md))))
  var tbl = initTable[int, int]()
  var n = 1
  for i in 0 ..< m:
    tbl[n] = i
    n = n * 7 mod md
  let factor = powMod(7, md - m - 1, md)
  n = door
  for i in 0 ..< m:
    if n in tbl:
      return powMod(card, i*m + tbl[n], md)
    n = n * factor mod md

proc part2*(input: string): string =
  nil
