import algorithm
import strutils

type
  St = enum
    Corrupted, Incomplete

  Return = object
    case kind: St
    of Corrupted: a: int
    of Incomplete: b: int

proc analyze(line: string): Return =
  var stack: seq[char]
  for c in line:
    let i = "([{<".find(c)
    if i != -1:
      stack.add(")]}>"[i])
    elif stack.pop != c:
      let a = if c == ')': 3
              elif c == ']': 57
              elif c == '}': 1197
              else: 25137
      return Return(kind: Corrupted, a: a)
  var sum = 0
  stack.reverse
  for c in stack:
    let b = ")]}>".find(c) + 1
    sum = sum * 5 + b
  Return(kind: Incomplete, b: sum)

proc part1*(input: string): int =
  for line in input.splitlines:
    let x = analyze(line)
    if x.kind == Corrupted:
      result += x.a

proc part2*(input: string): int =
  var ns: seq[int]
  for line in input.splitlines:
    let x = analyze(line)
    if x.kind == Incomplete:
      ns.add(x.b)
  ns.sort
  ns[ns.len div 2]
