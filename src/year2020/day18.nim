import tables
import streams
import strutils

let opTable = {
  '+': proc (a, b: int): int = a + b,
  '*': proc (a, b: int): int = a * b,
}.toTable

# Assumes single digits
proc calc(s: Stream, prec: Table[char, int]): int =
  var nums = newSeq[int]()
  var ops = newSeq[char]()
  while not s.atEnd:
    let c = s.readChar
    case c:
      of '0'..'9': nums.add(ord(c) - ord('0'))
      of '(': nums.add(calc(s, prec))
      of ')': break
      of '+', '*':
        if ops.len > 0 and prec[c] <= prec[ops[^1]]:
          nums.add(opTable[ops.pop()](nums.pop(), nums.pop()))
        ops.add(c)
      else: discard
  while ops.len > 0:
    nums.add(opTable[ops.pop()](nums.pop(), nums.pop()))
  nums[0]

proc solve(input:string, prec: Table[char, int]): int =
  for line in input.splitlines:
    result += calc(line.newStringStream, prec)

proc part1*(input: string): int =
  solve(input, {'+': 1, '*': 1}.toTable)

proc part2*(input: string): int =
  solve(input, {'+': 2, '*': 1}.toTable)
