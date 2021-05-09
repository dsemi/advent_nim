import fusion/matching
import re
import sequtils
import strutils

{.experimental: "caseStmtMacros".}

import "../utils"

proc parseDisc(line: string): (int, int) =
  case line.findAll(re"\d+").map(parseInt):
    of [@discNum, @modulo, _, @pos]:
      (-pos - discNum, modulo)
    else:
      raiseAssert "Parse failure: " & line

proc part1*(input: string): int =
  input.splitLines.map(parseDisc).chineseRemainder

const extra = "\nDisc #7 has 11 positions; at time=0, it is at position 0."

proc part2*(input: string): int =
  (input & extra).splitLines.map(parseDisc).chineseRemainder
