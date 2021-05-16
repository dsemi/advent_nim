import fusion/matching
import math
import sequtils
import strutils

proc part1*(input: string): int =
  for line in input.splitlines:
    [@l, @w, @h] := line.split('x').map(parseInt)
    let areas = [l * w, l * h, w * h]
    result += 2 * areas.sum + areas.min

proc part2*(input: string): int =
  for line in input.splitlines:
    [@l, @w, @h] := line.split('x').map(parseInt)
    result += 2 * [l + w, l + h, w + h].min + l * w * h
