import fusion/matching
import sequtils
import strutils
import sugar

proc solve(input: string, f: (int, int, int, int) -> bool): int =
  for line in input.splitLines:
    [[@a0, @a1], [@b0, @b1]] := line.split(',').mapIt(it.split('-').map(parseInt))
    if f(a0, a1, b0, b1):
      inc result

proc part1*(input: string): int =
  input.solve((a0, a1, b0, b1) => a0 <= b0 and a1 >= b1 or b0 <= a0 and b1 >= a1)

proc part2*(input: string): int =
  input.solve((a0, a1, b0, b1) => a0 <= b1 and b0 <= a1)
