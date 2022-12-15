import algorithm
import intsets
import options
import sequtils
import strscans
import strutils

import "../utils"

type Sensor = object
  x, y: int
  dist: int

proc parse(input: string): (seq[Sensor], IntSet) =
  for line in input.splitLines:
    var sx, sy, bx, by: int
    doAssert line.scanf("Sensor at x=$i, y=$i: closest beacon is at x=$i, y=$i", sx, sy, bx, by)
    let dist = abs(sx - bx) + abs(sy - by)
    result[0].add Sensor(x: sx, y: sy, dist: dist)
    if by == 2000000: result[1].incl bx

proc part1*(input: string): int =
  let (sensors, bs) = input.parse
  var intervals = newSeq[Interval[int]]()
  for sensor in sensors:
    let diff = sensor.dist - abs(sensor.y - 2000000)
    if diff >= 0:
      intervals.add Interval[int](lo: sensor.x - diff, hi: sensor.x + diff + 1)
  let interval = intervals.sortedByIt(it.lo).foldl(union(a, b))
  interval.len - bs.countIt(it in interval.lo..<interval.hi)

type Line = object
  sx, sy, ex, ey: int

proc intersect(a, b: Line): Option[Coord] =
  if a.sx <= b.ex and b.sx <= a.ex and a.sy <= b.sy and b.ey <= a.ey:
    let (p1, p2) = (b.sx + b.sy, a.sx - a.sy)
    return some ((p1 + p2) div 2, (p1 - p2) div 2)

proc part2*(input: string): int =
  let sensors = input.parse[0]
  var urs, drs: seq[Line]
  for s in sensors:
    urs.add Line(sx: s.x - s.dist - 1, sy: s.y, ex: s.x, ey: s.y + s.dist + 1)
    urs.add Line(sx: s.x, sy: s.y - s.dist - 1, ex: s.x + s.dist + 1, ey: s.y)
    drs.add Line(sx: s.x, sy: s.y + s.dist + 1, ex: s.x + s.dist + 1, ey: s.y)
    drs.add Line(sx: s.x - s.dist - 1, sy: s.y, ex: s.x, ey: s.y - s.dist - 1)
  for a in urs:
    for b in drs:
      let pt = intersect(a, b).get((-1, -1))
      if pt.x in 0..4000000 and pt.y in 0..4000000 and sensors.allIt(abs(pt - (it.x, it.y)).sum > it.dist):
        return 4000000*pt.x + pt.y
