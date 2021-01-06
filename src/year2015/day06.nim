import math
import re
import sequtils
import strutils
import sugar
import unpack

proc run(on, off, toggle: (int) -> int, input: string): int =
  var arr: array[1000, array[1000, int]]
  for line in input.splitlines:
    var caps: array[5, string]
    doAssert match(line, re"(turn on|turn off|toggle) (\d+),(\d+) through (\d+),(\d+)", caps)
    let cmd = caps[0]
    var f: (int) -> int
    case cmd:
      of "turn on": f = on
      of "turn off": f = off
      of "toggle": f = toggle
      else: doAssert false, "bad input"
    [x0, y0, x1, y1] <- caps[1 .. ^1].map(parseInt)
    for x in x0..x1:
      for y in y0..y1:
        arr[x][y] = f(arr[x][y])
  for row in arr:
    result += row.sum

proc part1*(input: string): int =
  run((_) => 1, (_) => 0, (x) => x xor 1, input)

proc part2*(input: string): int =
  run((x) => x + 1, (x) => max(0, x - 1), (x) => x + 2, input)
