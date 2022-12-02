import math
import strutils
import sugar

proc solve(input: string, f: (int, int) -> int): int =
  for line in input.splitLines:
    result += f(line[0].ord - 'A'.ord, line[2].ord - 'X'.ord)

proc part1*(input: string): int =
  solve(input, (a, b) => 3*floorMod(b - a + 1, 3) + b + 1)

proc part2*(input: string): int =
  solve(input, (a, b) => floorMod(a + b - 1, 3) + 3*b + 1)
