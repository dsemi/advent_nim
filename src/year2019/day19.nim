import "intcode"

proc isPulled(prog: Program, x, y: int): bool =
  var p: Program
  deepCopy(p, prog)
  p.send([x, y])
  p.run
  for o in p.recv:
    return o == 1

proc part1*(input: string): int =
  let prog = input.parse
  for x in 0..49:
    for y in 0..49:
      result += prog.isPulled(x, y).int

proc part2*(input: string): int =
  let prog = input.parse
  var (x, y) = (0, 0)
  while true:
    var p: Program
    deepCopy(p, prog)
    if p.isPulled(x + 99, y):
      break
    else:
      deepCopy(p, prog)
      if p.isPulled(x, y + 100):
        inc y
      else:
        inc x
        inc y
  x * 10000 + y
