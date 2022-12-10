import sequtils
import sets
import strscans
import strutils

import "../ocr"
import "../utils"

type Obj = object
  pos: Coord
  vel: Coord

proc parseObjects(input: string): seq[Obj] =
  for line in input.splitLines:
    var x0, y0, x1, y1: int
    doAssert line.scanf("position=<$s$i,$s$i> velocity=<$s$i,$s$i>", x0, y0, x1, y1)
    result.add(Obj(pos: (x0, y0), vel: (x1, y1)))

proc boundingBox(objs: seq[Obj]): (int, int, int, int) =
  result = (int.high, int.high, int.low, int.low)
  for obj in objs:
    result[0] = min(result[0], obj.pos[0])
    result[1] = min(result[1], obj.pos[1])
    result[2] = max(result[2], obj.pos[0])
    result[3] = max(result[3], obj.pos[1])

proc findMessage(objs: seq[Obj]): (int, seq[Obj]) =
  result[1] = objs
  var bb = result[1].boundingBox
  while bb[3] - bb[1] > 15:
    for obj in result[1].mitems:
      obj.pos += obj.vel
    bb = result[1].boundingBox
    inc result[0]

proc showObjects(objs: seq[Obj]): string =
  let lights = objs.mapIt(it.pos).toHashSet
  let (x0, y0, x1, y1) = objs.boundingBox
  var msg = ""
  for y in y0..y1:
    msg &= "\n"
    for x in x0..x1:
      msg &= (if (x, y) in lights: '#' else: ' ')
  msg.parseLetters(large = true)

proc part1*(input: string): string =
  input.parseObjects.findMessage[1].showObjects

proc part2*(input: string): int =
  input.parseObjects.findMessage[0]
