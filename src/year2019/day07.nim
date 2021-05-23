import deques
import itertools

import "intcode"

proc chain(prog: Program, phases: seq[int], cycle: bool = false): seq[int] =
  var progs: seq[Program]
  for _ in phases:
    var p: Program
    deepCopy(p, prog)
    progs.add(p)
  for i in progs.low..progs.high-1:
    progs[i+1].input = progs[i].output
  for i, p in phases:
    progs[i].input[].addLast(p)
  progs[0].input[].addLast(0)
  while true:
    for prog in progs.mitems:
      if prog.done: return result
      prog.run
    while progs[^1].output[].len > 0:
      let v = progs[^1].output[].popFirst
      if cycle:
        progs[0].input[].addLast(v)
      result.add(v)

proc part1*(input: string): int =
  let prog = input.parse
  for perm in [0, 1, 2, 3, 4].permutations:
    result = max(result, prog.chain(perm)[0])

proc part2*(input: string): int =
  let prog = input.parse
  for perm in [5, 6, 7, 8, 9].permutations:
    result = max(result, prog.chain(perm, cycle = true)[^1])
