import std/enumerate
import strutils

iterator run(input: string): int =
  var x = 1
  for tok in input.split:
    yield x
    case tok
    of "addx", "noop": discard
    else: x += tok.parseInt

proc part1*(input: string): int =
  for cycle, x in enumerate(1, input.run):
    if cycle mod 40 == 20:
      result += cycle * x

proc part2*(input: string): string =
  for c, x in enumerate(input.run):
    if c mod 40 == 0:
      result &= '\n'
    result.add(if abs(c mod 40 - x) <= 1: '#' else: ' ')
