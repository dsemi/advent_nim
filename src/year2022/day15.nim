import sequtils
import sets
import strscans
import strutils

import "../utils"

type Sensor = object
  pos: Coord
  dist: int

proc parse(input: string): (seq[Sensor], HashSet[Coord]) =
  for line in input.splitLines:
    var sx, sy, bx, by: int
    doAssert line.scanf("Sensor at x=$i, y=$i: closest beacon is at x=$i, y=$i", sx, sy, bx, by)
    let dist = abs(sx - bx) + abs(sy - by)
    result[0].add Sensor(pos: (sx, sy), dist: dist)
    result[1].incl((bx, by))

proc part1*(input: string): int =
  let (sensors, beacons) = input.parse
  var minX = int.high
  var maxX = int.low
  for sensor in sensors:
    minX = min(minX, sensor.pos.x - sensor.dist)
    maxX = max(maxX, sensor.pos.x + sensor.dist)
  let y = 2000000
  for x in minX..maxX:
    if (x, y) in beacons: continue
    if sensors.anyIt(abs(it.pos.x - x) + abs(it.pos.y - y) <= it.dist):
      inc result

proc part2*(input: string): int =
  let sensors = input.parse[0]
  for sens in sensors:
    let y0 = sens.pos.y
    for (x0, dir) in [(sens.pos.x - sens.dist - 1, ( 1,  1)),
                      (sens.pos.x - sens.dist - 1, ( 1, -1)),
                      (sens.pos.x + sens.dist + 1, (-1,  1)),
                      (sens.pos.x + sens.dist + 1, (-1, -1))]:
      for i in 0 .. sens.dist+1:
        let (x, y) = (x0 + i*dir[0], y0 + i*dir[1])
        if x notin 0..4000000 or y notin 0..4000000: continue
        if not sensors.anyIt(abs(x - it.pos.x) + abs(y - it.pos.y) <= it.dist):
          return 4000000*x + y
