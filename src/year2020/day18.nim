import regex
import tables
import strutils
import sugar

let opTable = {
  "+": proc (a, b: int): int = a + b,
  "*": proc (a, b: int): int = a * b,
}.toTable

proc calc(s: string, prec: Table[string, int]): int =
  var s = s
  while '(' in s:
    s = replace(s, re"\(([^()]+)\)", (m, s2) => $calc(s2[m.captures[0][0]], prec))
  var nums = newSeq[int]()
  var ops = newSeq[string]()
  for v in s.split(' '):
    if match(v, re"\d+"):
      nums.add(v.parseInt)
    else:
      if ops.len > 0 and prec.getOrDefault(v, 1) <= prec.getOrDefault(ops[^1], 1):
        nums.add(opTable[ops.pop()](nums.pop(), nums.pop()))
      ops.add(v)
  while ops.len > 0:
    nums.add(opTable[ops.pop()](nums.pop(), nums.pop()))
  nums[0]

proc solve(input:string, prec: Table[string, int] = initTable[string, int]()): int =
  for line in input.splitlines:
    result += calc(line, prec)

proc part1*(input: string): int =
  solve(input)

proc part2*(input: string): int =
  solve(input, {"+": 2}.toTable)
