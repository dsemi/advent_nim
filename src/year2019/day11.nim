import fusion/matching
import sequtils
import tables

import "../ocr"
import "../utils"
import "intcode"

{.experimental: "caseStmtMacros".}

proc runRobot(prog: var Program, t: Table[Coord, int]): Table[Coord, int] =
  var pos = (0, 0)
  var dir = (0, -1)
  result = t
  while not prog.done:
    prog.send([result.getOrDefault(pos, 0)])
    prog.run
    case toSeq(prog.recv):
      of [@col, @d]:
        result[pos] = col
        dir *= (if d == 1: (0, 1) else: (0, -1))
        pos += dir
      else: raiseAssert "Invalid response"

proc part1*(input: string): int =
  var prog = input.parse
  prog.runRobot(initTable[Coord, int]()).len

proc draw(points: Table[Coord, int]): string =
  var (minX, minY, maxX, maxY) = (int.high, int.high, int.low, int.low)
  for (x, y) in points.keys:
    minX = min(minX, x)
    minY = min(minY, y)
    maxX = max(maxX, x)
    maxY = max(maxY, y)
  var panel = ""
  for y in minY..maxY:
    panel &= "\n"
    for x in minX..maxX:
      panel &= (if points.getOrDefault((x, y), 0) == 0: ' ' else: '#')
  panel.parseLetters

proc part2*(input: string): string =
  var prog = input.parse
  prog.runRobot({(0, 0): 1}.toTable).draw
