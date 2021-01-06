import strutils

proc part1*(input: string): int =
  for i, c in input:
    if c == input[(i+1) mod input.len]:
      result += ($c).parseInt

proc part2*(input: string): int =
  for i, c in input:
    if c == input[(i+input.len div 2) mod input.len]:
      result += ($c).parseInt
