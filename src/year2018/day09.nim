import lists
import strscans
import tables

import "../utils"

proc parse(input: string): (int, int) =
  doAssert input.scanf("$i players; last marble is worth $i points", result[0], result[1])

proc play(n, s: int): int =
  var m: CountTable[int]
  var list = initCircularList[int](0)
  for p in 1..s:
    if p mod 23 != 0:
      list.moveRight(1)
      list.insert(p)
      continue
    list.moveLeft(7)
    let v = list.pop
    m.inc(p mod n, p + v)
  result = int.low
  for v in m.values:
    result = max(result, v)

proc part1*(input: string): int =
  let (a, b) = input.parse
  play(a, b)

proc part2*(input: string): int =
  let (a, b) = input.parse
  play(a, b * 100)
