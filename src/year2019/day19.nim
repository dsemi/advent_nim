import sequtils
import sugar

import "intcode"
import "../utils"

proc isPulled(prog: Program, x, y: int): bool =
  var p = deepCopy(prog)
  p.send([x, y])
  p.run
  for o in p.recv:
    return o == 1

proc part1*(input: string): int =
  let prog = input.parse
  var (minX, maxX) = (0, 0)
  for y in 0..49:
    for x in minX..49:
      if prog.isPulled(x, y):
        minX = x
        for x in max(minX, maxX)..49:
          if not prog.isPulled(x, y):
            maxX = x
            break
        result += maxX - minX
        break

proc part2*(input: string): int =
  let prog = input.parse
  var x = 99
  var y: int
  for i in 0..int.high:
    if prog.isPulled(x, i):
      y = i
      break
  while not prog.isPulled(x-99, y+99):
    y *= 2
    for i in x*2+1..int.high:
      if not prog.isPulled(i, y):
        x = i - 1
        break
  let xs = toSeq(x div 2 .. x)
  let ys = toSeq(y div 2 .. y)
  let i = ys.partitionPoint(proc(y: int): bool =
                              let i = xs.partitionPoint(x => prog.isPulled(x, y)) - 1
                              not prog.isPulled(xs[i] - 99, y + 99))
  # Small buffer since fitting square isn't fully ordered.
  for y in ys[i]-5 .. int.high:
    let i = xs.partitionPoint(x => prog.isPulled(x, y)) - 1
    x = xs[i] - 99
    if prog.isPulled(x, y + 99):
      return x * 10000 + y
