import re
import strformat
import strutils
import sugar
import tables
import unpack

proc parseWires(input: string): Table[string, () -> uint16] =
  var tbl = initTable[string, () -> uint16]()
  var dp = initTable[string, uint16]()
  proc val(x: string): uint16 =
    if x in dp:
      return dp[x]
    try:
      return uint16(x.parseInt)
    except ValueError:
     result = tbl[x]()
     dp[x] = result
  for line in input.splitlines:
    var caps: array[5, string]
    doAssert match(line, re"(?:((\w+) (AND|OR|LSHIFT|RSHIFT)|NOT) )?(\w+) -> (\w+)", caps)
    [aop, a, op, b, v] <- caps
    capture a, b:
      if aop == "":
        tbl[v] = () => val(b)
      elif aop == "NOT":
        tbl[v] = () => not val(b)
      elif op == "AND":
        tbl[v] = () => val(a) and val(b)
      elif op == "OR":
        tbl[v] = () => val(a) or val(b)
      elif op == "LSHIFT":
        tbl[v] = () => val(a) shl val(b)
      elif op == "RSHIFT":
        tbl[v] = () => val(a) shr val(b)
  tbl

proc part1*(input: string): uint16 =
  parseWires(input)["a"]()

proc part2*(input: string): uint16 =
  let a = parseWires(input)["a"]()
  parseWires(input & "\n{a} -> b".fmt)["a"]()
