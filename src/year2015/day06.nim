import math
import strscans
import strutils
import sugar

proc run(on, off, toggle: (int) -> int, input: string): int =
  var arr: array[1000, array[1000, int]]
  for line in input.splitlines:
    var x0, y0, x1, y1: int
    var f: (int) -> int
    if line.scanf("turn on $i,$i through $i,$i", x0, y0, x1, y1):
      f = on
    elif line.scanf("turn off $i,$i through $i,$i", x0, y0, x1, y1):
      f = off
    else:
      doAssert line.scanf("toggle $i,$i through $i,$i", x0, y0, x1, y1)
      f = toggle
    for x in x0..x1:
      for y in y0..y1:
        arr[x][y] = f(arr[x][y])
  for row in arr:
    result += row.sum

proc part1*(input: string): int =
  run((_) => 1, (_) => 0, (x) => x xor 1, input)

proc part2*(input: string): int =
  run((x) => x + 1, (x) => max(0, x - 1), (x) => x + 2, input)
