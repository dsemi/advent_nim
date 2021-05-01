import algorithm
import fusion/matching
import sequtils
import strformat
import strutils
import sugar
import tables

import "../utils"

{.experimental: "caseStmtMacros".}

proc runFactory(input: string): Table[string, seq[int]] =
  var tbl: Table[string, seq[() -> int]]
  for line in input.splitlines:
    case line.splitWhitespace:
      of ["bot", @n, _, _, _, @o1, @n1, _, _, _, @o2, @n2]:
        capture n:
          tbl.mgetOrPut(fmt"{o1} {n1}", @[]).add(lazy(() => tbl[fmt"bot {n}"].map(force).min))
          tbl.mgetOrPut(fmt"{o2} {n2}", @[]).add(lazy(() => tbl[fmt"bot {n}"].map(force).max))
      of ["value", @v, _, _, @o, @n]:
        capture v:
          tbl.mgetOrPut(fmt"{o} {n}", @[]).add(lazy(() => v.parseInt))
      else:
        raiseAssert fmt"Parse failed: {line}"
  for (k, v) in tbl.pairs:
    result[k] = v.map(force).sorted

proc part1*(input: string): string =
  let tbl = runFactory(input)
  for (k, vals) in tbl.pairs:
    if vals == @[17, 61]:
      return k.splitWhitespace[1]

proc part2*(input: string): int =
  let tbl = runFactory(input)
  tbl["output 0"][0] *
  tbl["output 1"][0] *
  tbl["output 2"][0]
