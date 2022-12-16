import algorithm
import math
import pegs
import sequtils
import strutils
import sugar

type Monkey = object
  heldItems: seq[int]
  op: (b: int) -> int
  divisor, trueIdx, falseIdx: int

let grammar = peg"""grammar <- header \n starting \n op \n test \n true \n false
                    header <- 'Monkey ' \d+ ':'
                    starting <- '  Starting items: ' {\d+ (', ' \d+)*}
                    op <- '  Operation: new = old ' {.} ' ' {('old' / \d+)}
                    test <- '  Test: divisible by ' {\d+}
                    true <- '    If true: throw to monkey ' {\d+}
                    false <- '    If false: throw to monkey ' {\d+}"""

proc parseMonkey(inp: string): Monkey =
  if inp =~ grammar:
    result.heldItems = matches[0].split(", ").map(parseInt)
    if matches[2] == "old":
      result.op = (b: int) => b * b
    else:
      let n = matches[2].parseInt
      case matches[1][0]
      of '+': result.op = (b: int) => b + n
      of '*': result.op = (b: int) => b * n
      else: raiseAssert "Invalid operator: " & matches[1][0]
    result.divisor = matches[3].parseInt
    result.trueIdx = matches[4].parseInt
    result.falseIdx = matches[5].parseInt

proc solve(input: string, p2: bool): int =
  var mks = collect(for blk in input.split("\n\n"): parseMonkey(blk))
  let m = mks.mapIt(it.divisor).lcm
  var inspections = newSeq[int](mks.len)
  let iters = if p2: 10000 else: 20
  for _ in 1..iters:
    for i in mks.low .. mks.high:
      inspections[i] += mks[i].heldItems.len
      for it in mks[i].heldItems:
        let worryLevel = if p2: mks[i].op(it) mod m
                         else: mks[i].op(it) div 3
        if worryLevel mod mks[i].divisor == 0:
          mks[mks[i].trueIdx].heldItems.add(worryLevel)
        else:
          mks[mks[i].falseIdx].heldItems.add(worryLevel)
      mks[i].heldItems.setLen(0)
  inspections.sort(order = Descending)
  inspections[0] * inspections[1]

proc part1*(input: string): int =
  input.solve(false)

proc part2*(input: string): int =
  input.solve(true)
