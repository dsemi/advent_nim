import algorithm
import math
import strutils

proc part1*(input: string): string =
  var num = 0
  for line in input.splitLines:
    for i, c in line.reversed:
      num += 5^i * ("=-012".find(c) - 2)
  while num > 0:
    result.add "012=-"[num mod 5]
    num = (num + 2) div 5
  result.reverse

proc part2*(input: string): string =
  " "
