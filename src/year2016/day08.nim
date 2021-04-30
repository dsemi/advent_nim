import re
import sets
import sequtils
import strutils
import sugar
import unpack

import "../utils"

let
  w = 50
  h = 6
  rect = re"rect (\d+)x(\d+)"
  rotateR = re"rotate row y=(\d+) by (\d+)"
  rotateC = re"rotate column x=(\d+) by (\d+)"

proc processInstr(grid: var HashSet[Coord], line: string) =
  var cap: array[2, string]
  if match(line, rect, cap):
    [width, height] <- cap.map(parseInt)
    for c in 0..<width:
      for r in 0..<height:
        grid.incl((r, c))
  elif match(line, rotateR, cap):
    [row, amt] <- cap.map(parseInt)
    grid = collect(initHashSet):
      for (r, c) in grid:
        {(r, if r == row: (c + amt) mod w else: c)}
  else:
    doAssert match(line, rotateC, cap)
    [col, amt] <- cap.map(parseInt)
    grid = collect(initHashSet):
      for (r, c) in grid:
        {((if c == col: (r + amt) mod h else: r), c)}

proc litPixels(input: string): HashSet[Coord] =
  for line in input.splitLines:
    processInstr(result, line)

proc part1*(input: string): int =
  litPixels(input).len

proc part2*(input: string): string =
  let pix = litPixels(input)
  var display: seq[seq[char]]
  for r in 0..<h:
    display.add(@[])
    for c in 0..<w:
      if (r, c) in pix:
        display[r].add('#')
      else:
        display[r].add(' ')
  "\n" & display.mapIt(it.join).join("\n")
