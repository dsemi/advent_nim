import sequtils
import strutils
import tables

import "../utils"

proc run(r: Table[string, int], input: string): int =
  var r = r
  let instrs = input.replace(",", "").splitlines.mapIt(it.split)
  var i = 0
  while i >= 0 and i < instrs.len:
    let instr = instrs[i]
    case instr[0]:
      of "hlf": r[instr[1]] //= 2
      of "tpl": r[instr[1]] *= 3
      of "inc": r[instr[1]] += 1
      of "jmp": i += instr[1].parseInt - 1
      of "jie":
        if r[instr[1]] mod 2 == 0:
          i += instr[2].parseInt - 1
      of "jio":
        if r[instr[1]] == 1:
          i += instr[2].parseInt - 1
      else: discard
    i += 1
  r["b"]

proc part1*(input: string): int =
  run({"a": 0, "b": 0}.toTable, input)

proc part2*(input: string): int =
  run({"a": 1, "b": 0}.toTable, input)
