import fusion/matching
import strutils
import sugar
import tables

{.experimental: "caseStmtMacros".}

proc runCmd(reg: var CountTable[string], line: string): int =
  case line.splitWhitespace
  of [@r, @op, @n, "if", @r2, @cond, @n2]:
    let cmpFn = case cond
                of "==": (a, b: int) => a == b
                of "!=": (a, b: int) => a != b
                of ">": (a, b: int) => a > b
                of ">=": (a, b: int) => a >= b
                of "<": (a, b: int) => a < b
                of "<=": (a, b: int) => a <= b
                else: raiseAssert "Parse cond error: " & cond
    if cmpFn(reg[r2], n2.parseInt):
      let v = case op
              of "inc": n.parseInt
              of "dec": -n.parseInt
              else: raiseAssert "Parse op error: " & op
      reg.inc(r, v)
    return reg[r]
  else: raiseAssert "Parse error: " & line

proc part1*(input: string): int =
  var tbl: CountTable[string]
  for line in input.splitLines:
    discard runCmd(tbl, line)
  tbl.largest[1]

proc part2*(input: string): int =
  result = int.low
  var tbl: CountTable[string]
  for line in input.splitLines:
    result = max(result, runCmd(tbl, line))
