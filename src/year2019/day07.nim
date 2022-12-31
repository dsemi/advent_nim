import algorithm

import "intcode"

proc chain(prog: Program, phases: seq[int], cycle: bool = false): seq[int] =
  var progs: seq[Program]
  for _ in phases:
    progs.add deepCopy(prog)
  for i in progs.low..progs.high-1:
    progs[i+1].input = progs[i].output
  for i, p in phases:
    progs[i].send([p])
  progs[0].send([0])
  while true:
    for prog in progs.mitems:
      if prog.done: return result
      prog.run
    for v in progs[^1].recv:
      if cycle:
        progs[0].send([v])
      result.add(v)

proc part1*(input: string): int =
  let prog = input.parse
  var perm = @[0, 1, 2, 3, 4]
  var run = true
  while run:
    result = max(result, prog.chain(perm)[0])
    run = perm.nextPermutation

proc part2*(input: string): int =
  let prog = input.parse
  var perm = @[5, 6, 7, 8, 9]
  var run = true
  while run:
    result = max(result, prog.chain(perm, cycle = true)[^1])
    run = perm.nextPermutation
