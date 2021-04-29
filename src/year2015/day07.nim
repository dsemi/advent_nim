import re
import strformat
import strutils
import sugar
import tables
import unpack

import "../utils"

proc parseWires(input: string): Table[string, () -> uint16] =
  var tbl: Table[string, () -> uint16]
  proc val(x: string): uint16 =
    try:
      return uint16(x.parseInt)
    except ValueError:
     return tbl[x]()
  let reg = re"(?:((\w+) (AND|OR|LSHIFT|RSHIFT)|NOT) )?(\w+) -> (\w+)"
  for line in input.splitlines:
    var caps: array[5, string]
    doAssert match(line, reg, caps)
    [aop, a, op, b, v] <- caps
    capture a, b:
      if aop == "":
        tbl[v] = lazy(() => val(b))
      elif aop == "NOT":
        tbl[v] = lazy(() => not val(b))
      elif op == "AND":
        tbl[v] = lazy(() => val(a) and val(b))
      elif op == "OR":
        tbl[v] = lazy(() => val(a) or val(b))
      elif op == "LSHIFT":
        tbl[v] = lazy(() => val(a) shl val(b))
      elif op == "RSHIFT":
        tbl[v] = lazy(() => val(a) shr val(b))
  tbl

proc part1*(input: string): uint16 =
  parseWires(input)["a"]()

proc part2*(input: string): uint16 =
  let a = parseWires(input)["a"]()
  parseWires(input & "\n{a} -> b".fmt)["a"]()
