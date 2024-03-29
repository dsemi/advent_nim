import strscans
import strutils
import sugar

proc solve(input: string, f: (int, int, int, int) -> bool): int =
  var a0, a1, b0, b1: int
  for line in input.splitLines:
    doAssert line.scanf("$i-$i,$i-$i", a0, a1, b0, b1)
    result += f(a0, a1, b0, b1).int

proc part1*(input: string): int =
  input.solve((a0, a1, b0, b1) => a0 <= b0 and a1 >= b1 or b0 <= a0 and b1 >= a1)

proc part2*(input: string): int =
  input.solve((a0, a1, b0, b1) => a0 <= b1 and b0 <= a1)
