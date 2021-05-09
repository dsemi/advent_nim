import fusion/matching
import strformat
import strutils
import sugar
import tables

import "../utils"

{.experimental: "caseStmtMacros".}

proc parseWires(input: string): Table[string, () -> uint16] =
  var tbl: Table[string, () -> uint16]
  proc val(x: string): uint16 =
    try:
      return uint16(x.parseInt)
    except ValueError:
     return tbl[x]()
  for line in input.splitlines:
    case line.splitWhitespace:
      of [@b, "->", @v]:
        capture b: tbl[v] = lazy(() => val(b))
      of ["NOT", @b, "->", @v]:
        capture b: tbl[v] = lazy(() => not val(b))
      of [@a, "AND", @b, "->", @v]:
        capture a, b: tbl[v] = lazy(() => val(a) and val(b))
      of [@a, "OR", @b, "->", @v]:
        capture a, b: tbl[v] = lazy(() => val(a) or val(b))
      of [@a, "LSHIFT", @b, "->", @v]:
        capture a, b: tbl[v] = lazy(() => val(a) shl val(b))
      of [@a, "RSHIFT", @b, "->", @v]:
        capture a, b: tbl[v] = lazy(() => val(a) shr val(b))
  tbl

proc part1*(input: string): uint16 =
  parseWires(input)["a"]()

proc part2*(input: string): uint16 =
  let a = parseWires(input)["a"]()
  parseWires(input & "\n{a} -> b".fmt)["a"]()
