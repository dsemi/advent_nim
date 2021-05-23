import "intcode"

proc part1*(input: string): int =
  var prog = input.parse
  prog.send([1])
  prog.run
  for o in prog.recv:
    result = o

proc part2*(input: string): int =
  var prog = input.parse
  prog.send([5])
  prog.run
  for o in prog.recv:
    result = o
