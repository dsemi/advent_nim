import fusion/matching
import sequtils
import strutils

proc parseFirewall(input: string): seq[(int, int)] =
  for line in input.splitLines:
    [@a, @b] := line.split(": ").map(parseInt)
    result.add((a, 2*b-2))

proc part1*(input: string): int =
  for (a, b) in input.parseFirewall:
    if a mod b == 0:
      result += a * (b + 2) div 2

proc part2*(input: string): int =
  let scrs = input.parseFirewall
  for i in 0..int.high:
    if scrs.allIt((it[0] + i) mod it[1] != 0):
      return i
