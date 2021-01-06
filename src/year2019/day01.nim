import strutils

proc part1*(input: string): int =
  for line in input.splitlines:
    result += line.parseInt div 3 - 2

proc part2*(input: string): int =
  for line in input.splitlines:
    var fuel = line.parseInt div 3 - 2
    while fuel > 0:
      result += fuel
      fuel = fuel div 3 - 2
