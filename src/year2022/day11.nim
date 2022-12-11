import algorithm
import math
import sequtils
import strscans
import strutils
import sugar

import "../utils"

type Monkey = object
  num: int
  heldItems: seq[int]
  op: (b: int) -> int
  divisor: int
  trueNum: int
  falseNum: int

const monkStr = """Monkey $i:
  Starting items: ${dlist}
  Operation: new = old $c $*
  Test: divisible by $i
    If true: throw to monkey $i
    If false: throw to monkey $i"""

proc parseMonkey(inp: string): Monkey =
  var c: char
  var op: string
  doAssert inp.scanf(monkStr, result.num, result.heldItems, c, op,
                     result.divisor, result.trueNum, result.falseNum)
  if op == "old":
    result.op = (b: int) => b * b
    return result
  let n = op.parseInt
  if c == '+':
    result.op = (b: int) => b + n
  elif c == '*':
    result.op = (b: int) => b * n
  else:
    raiseAssert "Invalid operator: " & c

proc solve(input: string, p2: bool): int =
  var mks = collect:
    for blk in input.split("\n\n"):
      parseMonkey(blk)
  let m = mks.mapIt(it.divisor).lcm
  var inspections = newSeq[int](mks.len)
  let iters = if p2: 10000 else: 20
  for _ in 1..iters:
    for i in mks.low .. mks.high:
      inspections[i] += mks[i].heldItems.len
      for it in mks[i].heldItems:
        var worryLevel = mks[i].op(it)
        if p2: worryLevel = worryLevel mod m
        else: worryLevel = worryLevel div 3
        if worryLevel mod mks[i].divisor == 0:
          mks[mks[i].trueNum].heldItems.add(worryLevel)
        else:
          mks[mks[i].falseNum].heldItems.add(worryLevel)
      mks[i].heldItems.setLen(0)
  inspections.sort(order = Descending)
  inspections[0] * inspections[1]

proc part1*(input: string): int =
  input.solve(false)

proc part2*(input: string): int =
  input.solve(true)
