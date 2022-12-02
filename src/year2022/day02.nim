import strutils
import sugar

proc solve(input: string, conv: (char, int) -> int): int =
  for line in input.splitLines:
    let a = line[0].ord - 'A'.ord
    let b = conv(line[2], a)
    let wld = if b == (a + 1) mod 3: 6
              elif b == a: 3
              else: 0
    result += wld + b + 1

proc part1*(input: string): int =
  proc conv(c: char, a: int): int =
    case c:
      of 'X': 0
      of 'Y': 1
      of 'Z': 2
      else: raiseAssert "Malformed input"
  solve(input, conv)

proc part2*(input: string): int =
  proc conv(c: char, a: int): int =
    case c:
      of 'X': (a + 2) mod 3
      of 'Y': a
      of 'Z': (a + 1) mod 3
      else: raiseAssert "Malformed input"
  solve(input, conv)
