import deques
import strscans
import tables

proc parse(input: string): (int, int) =
  doAssert input.scanf("$i players; last marble is worth $i points", result[0], result[1])

proc play(n, s: int): int =
  var m: CountTable[int]
  var list = [0].toDeque
  for p in 1..s:
    if p mod 23 != 0:
      let x = list.popFirst
      list.addLast(x)
      list.addLast(p)
      continue
    for _ in 1..7:
      let x = list.popLast
      list.addFirst(x)
    let v = list.popLast
    let x = list.popFirst
    list.addLast(x)
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
