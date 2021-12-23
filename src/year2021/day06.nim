import math
import sequtils

proc solve(s: string, n: int): int =
  var fish = toSeq('0'..'8').mapIt(s.count(it))
  for i in 0..<n:
    fish[(i + 7) mod 9] += fish[i mod 9]
  fish.sum

proc part1*(input: string): int =
  solve(input, 80)

proc part2*(input: string): int =
  solve(input, 256)
