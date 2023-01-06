import math
import sequtils
import strutils
import sugar

const SkipSize = 25

type Node = ref object
  val: int
  prev {.cursor.}: Node
  next {.cursor.}: Node
  farPrev {.cursor.}: Node
  farNext {.cursor.}: Node

proc mix(input: string, scale = 1, times = 1): int =
  let ns = input.splitLines.mapIt(Node(val: it.parseInt * scale))
  let m = ns.len - 1
  for i in ns.low .. ns.high:
    ns[(i+1) mod ns.len].prev = ns[i]
    ns[i].next = ns[(i+1) mod ns.len]
    ns[(i+SkipSize) mod ns.len].farPrev = ns[i]
    ns[i].farNext = ns[(i+SkipSize) mod ns.len]
  template fixRefs(a, b) =
    for _ in 0..SkipSize:
      a.farNext = b
      b.farPrev = a
      a = a.next
      b = b.next
  for _ in 1..times:
    for n in ns:
      # Remove
      var a = n.farPrev
      var b = n.next
      n.prev.next = n.next
      n.next.prev = n.prev
      fixRefs(a, b)
      # Find new pos
      var toMove = floorMod(n.val, m)
      b = n.next
      let (farStep, step) = if toMove > m div 2:
                              toMove = m - toMove
                              ((x: Node) => x.farPrev, (x: Node) => x.prev)
                            else:
                              ((x: Node) => x.farNext, (x: Node) => x.next)
      while toMove > 0 and toMove >= SkipSize:
        toMove -= SkipSize
        b = farStep(b)
      for _ in 1..toMove:
        b = step(b)
      # Insert
      b.prev.next = n
      n.prev = b.prev
      b.prev = n
      n.next = b
      a = b.farPrev
      b = n
      fixRefs(a, b)
  var cur: Node
  for n in ns:
    if n.val == 0:
      cur = n
      break
  for _ in 1..3:
    for _ in 1..1000:
      cur = cur.next
    result += cur.val

proc part1*(input: string): int =
  input.mix

proc part2*(input: string): int =
  input.mix(811589153, 10)
