import std/enumerate
import strutils

iterator run(input: string): (int, int) =
  var x = 1
  for i, tok in enumerate(input.split):
    yield (i+1, x)
    case tok
    of "addx", "noop": discard
    else: x += tok.parseInt

proc part1*(input: string): int =
  for (cycle, x) in input.run:
    if cycle in {20, 60, 100, 140, 180, 220}:
      result += cycle * x

proc part2*(input: string): string =
  result = "\n"
  for (cycle, x) in input.run:
    result.add(if abs((cycle - 1) mod 40 - x) <= 1: '#' else: ' ')
    if cycle < 240 and cycle mod 40 == 0:
      result &= "\n"
