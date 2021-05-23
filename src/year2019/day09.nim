import deques

import "intcode"

proc part1*(input: string): int =
  var prog = input.parse
  prog.input[].addLast(1)
  prog.run
  prog.output[][0]

proc part2*(input: string): int =
  var prog = input.parse
  prog.input[].addLast(2)
  prog.run
  prog.output[][0]
