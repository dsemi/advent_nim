import algorithm
import intsets
import sequtils
import strscans
import strutils

import "../utils"

type Sensor = object
  pos: Coord
  dist: int

proc parse(input: string): (seq[Sensor], IntSet) =
  for line in input.splitLines:
    var sx, sy, bx, by: int
    doAssert line.scanf("Sensor at x=$i, y=$i: closest beacon is at x=$i, y=$i", sx, sy, bx, by)
    let dist = abs(sx - bx) + abs(sy - by)
    result[0].add Sensor(pos: (sx, sy), dist: dist)
    if by == 2000000: result[1].incl bx

proc part1*(input: string): int =
  let (sensors, bs) = input.parse
  let y = 2000000
  var intervals = newSeq[Interval[int]]()
  for sensor in sensors:
    let diff = sensor.dist - abs(sensor.pos.y - y)
    if diff < 0: continue
    intervals.add Interval[int](lo: sensor.pos.x - diff, hi: sensor.pos.x + diff + 1)
  let interval = intervals.sortedByIt(it.lo).foldl(union(a, b))
  interval.len - bs.countIt(it in interval.lo..<interval.hi)

type Line = object
  s, e: Coord

proc intersect(a, b: Line): Coord =
  if a.s.x <= b.e.x and b.s.x <= a.e.x and a.s.y <= b.s.y and b.e.y <= a.e.y:
    let (p1, p2) = (b.s.x + b.s.y, a.s.x - a.s.y)
    return ((p1 + p2) div 2, (p1 - p2) div 2)
  (-1, -1)

proc part2*(input: string): int =
  let sensors = input.parse[0]
  var urs, drs: seq[Line]
  for s in sensors:
    urs.add Line(s: (s.pos.x - s.dist - 1, s.pos.y), e: (s.pos.x, s.pos.y + s.dist + 1))
    urs.add Line(s: (s.pos.x, s.pos.y - s.dist - 1), e: (s.pos.x + s.dist + 1, s.pos.y))
    drs.add Line(s: (s.pos.x, s.pos.y + s.dist + 1), e: (s.pos.x + s.dist + 1, s.pos.y))
    drs.add Line(s: (s.pos.x - s.dist - 1, s.pos.y), e: (s.pos.x, s.pos.y - s.dist - 1))
  for a in urs:
    for b in drs:
      let (x, y) = intersect(a, b)
      if x notin 0..4000000 or y notin 0..4000000: continue
      if not sensors.anyIt(abs(x - it.pos.x) + abs(y - it.pos.y) <= it.dist):
        return 4000000*x + y
