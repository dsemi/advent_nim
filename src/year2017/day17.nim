import lists
import strutils

proc part1*(input: string): int =
  let step = input.parseInt
  var curr = newSinglyLinkedNode[int](0)
  curr.next = curr
  for v in 1..2017:
    for _ in 1..step:
      curr = curr.next
    var next = newSinglyLinkedNode[int](v)
    next.next = curr.next
    curr.next = next
    curr = next
  curr.next.value

proc part2*(input: string): int =
  let step = input.parseInt
  var (i, idxOf0, valAft0) = (0, 0, 0)
  for v in 1..50_000_000:
    i = (i + step) mod v + 1
    if i <= idxOf0:
      inc idxOf0
    elif i == idxOf0 + 1:
      valAft0 = v
  valAft0
