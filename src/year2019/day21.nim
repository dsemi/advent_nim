import sequtils
import strutils

import "intcode"

const instrs = [
  "OR A T",
  "AND B T",
  "AND C T",
  "NOT T J",
  "AND D J",
  "WALK\n",
].join("\n")

proc part1*(input: string): int =
  var prog = input.parse
  prog.send(instrs.mapIt(it.ord))
  prog.run
  for o in prog.recv:
    result = o

const instrs2 = [
  "OR A T",
  "AND B T",
  "AND C T",
  "NOT T J",
  "AND D J",
  "NOT J T",
  "OR E T",
  "OR H T",
  "AND T J",
  "RUN\n",
].join("\n")

proc part2*(input: string): int =
  var prog = input.parse
  prog.send(instrs2.mapIt(it.ord))
  prog.run
  for o in prog.recv:
    result = o
