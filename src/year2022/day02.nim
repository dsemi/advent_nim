import math
import strutils
import sugar

proc solve(input: string, conv: (int, int) -> int): int =
  for line in input.splitLines:
    let a = line[0].ord - 'A'.ord
    let b = conv(line[2].ord - 'X'.ord, a)
    let wld = if b == (a + 1) mod 3: 6
              elif b == a: 3
              else: 0
    result += wld + b + 1

proc part1*(input: string): int =
  solve(input, (c, a) => c)

proc part2*(input: string): int =
  solve(input, (c, a) => floorMod(a + c - 1, 3))
