import deques

import "intcode"

proc part1*(input: string): int =
  var prog = input.parse
  prog.input[].addLast(1)
  prog.run
  prog.output[][^1]

proc part2*(input: string): int =
  var prog = input.parse
  prog.input[].addLast(5)
  prog.run
  prog.output[][^1]
