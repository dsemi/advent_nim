import lists
import math
import sequtils
import strutils

proc nodes(input: string, scale = 1): seq[DoublyLinkedNode[int]] =
  for i, n in input.splitLines.map(parseInt):
    result.add newDoublyLinkedNode[int](n * scale)
    if i > 0:
      result[^2].next = result[^1]
      result[^1].prev = result[^2]
  result[0].prev = result[^1]
  result[^1].next = result[0]

proc mix(ns: seq[DoublyLinkedNode[int]], times = 1): int =
  for _ in 1..times:
    for n in ns:
      n.prev.next = n.next
      n.next.prev = n.prev
      var (a, b) = (n.prev, n.next)
      let steps = floorMod(n.value, ns.len - 1)
      for _ in 1..steps:
        a = a.next
        b = b.next
      a.next = n
      n.prev = a
      b.prev = n
      n.next = b
  for n in ns:
    if n.value == 0:
      var n = n
      for i in 1..3000:
        n = n.next
        if i mod 1000 == 0:
          result += n.value
      break

proc part1*(input: string): int =
  input.nodes.mix

proc part2*(input: string): int =
  input.nodes(811589153).mix(10)
