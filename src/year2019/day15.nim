import deques
import sets

import "../utils"
import "intcode"

iterator search(prog: Program): (int, bool, Program) =
  var start = (0, 0)
  var visited = [start].toHashSet
  var frontier = [(0, false, start, prog)].toDeque
  while frontier.len > 0:
    var (d, b, st, p) = frontier.popFirst
    yield (d, b, p)
    for i, dir in [(0, 1), (0, -1), (-1, 0), (1, 0)]:
      let st2 = st + dir
      if st2 notin visited:
        visited.incl(st2)
        let n = i + 1
        p.send([n])
        p.run
        var r: int
        var j: int
        for o in p.recv:
          if j > 0:
            raiseAssert "Too many outputs"
          r = o
          inc j
        if r == 1 or r == 2:
          var p2: Program
          deepCopy(p2, p)
          frontier.addLast((d+1, r == 2, st2, p2))
          p.send([if n == 4: 3 elif n == 3: 4 elif n == 2: 1 else: 2])
          p.run
          p.output[].clear()

proc part1*(input: string): int =
  for (d, b, _) in input.parse.search:
    if b:
      return d

proc part2*(input: string): int =
  var prog: Program
  for (_, b, p) in input.parse.search:
    if b:
      prog = p
      break
  for (d, _, _) in prog.search:
    result = d
