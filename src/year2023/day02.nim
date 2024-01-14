import std/enumerate
import std/strutils

proc game(line: string): tuple[red: int, green: int, blue:int] =
  for roll in line.split("; "):
    var r, g, b: int
    for cube in roll.split(", "):
      if cube.endsWith("red"):
        r += cube[0..^5].parseInt
      elif cube.endsWith("green"):
        g += cube[0..^7].parseInt
      else:
        b += cube[0..^6].parseInt
    result.red = max(result.red, r)
    result.green = max(result.green, g)
    result.blue = max(result.blue, b)

proc part1*(input: string): int =
  for i, line in enumerate(1, input.splitLines):
    let (r, g, b) = game(line[line.find(':') + 2 .. ^1])
    if r <= 12 and g <= 13 and b <= 14:
      result += i

proc part2*(input: string): int =
  for line in input.splitLines:
    let (r, g, b) = game(line[line.find(':') + 2 .. ^1])
    result += r * g * b
