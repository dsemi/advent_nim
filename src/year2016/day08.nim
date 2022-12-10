import sets
import sequtils
import strscans
import strutils
import sugar

import "../ocr"
import "../utils"

const
  w = 50
  h = 6

proc processInstr(grid: var HashSet[Coord], line: string) =
  var a, b: int
  if line.scanf("rect $ix$i", a, b):
    for c in 0..<a:
      for r in 0..<b:
        grid.incl((r, c))
  elif line.scanf("rotate row y=$i by $i", a, b):
    grid = collect(initHashSet):
      for (r, c) in grid:
        {(r, if r == a: (c + b) mod w else: c)}
  else:
    doAssert line.scanf("rotate column x=$i by $i", a, b)
    grid = collect(initHashSet):
      for (r, c) in grid:
        {((if c == a: (r + b) mod h else: r), c)}

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
  display.mapIt(it.join).join("\n").parseLetters
