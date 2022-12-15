import algorithm
import intsets
import sequtils
import strscans
import strutils

import "../utils"

const p1Row = 2000000

type Sensor = object
  pos: Coord
  dist: int

proc parse(input: string): (seq[Sensor], IntSet) =
  for line in input.splitLines:
    var sx, sy, bx, by: int
    doAssert line.scanf("Sensor at x=$i, y=$i: closest beacon is at x=$i, y=$i", sx, sy, bx, by)
    let dist = abs(sx - bx) + abs(sy - by)
    result[0].add Sensor(pos: (sx, sy), dist: dist)
    if by == p1Row: result[1].incl bx

type Interval = object
  lo, hi: int

proc intersects(a, b: Interval): bool =
  a.lo <= b.hi and b.lo <= a.hi

proc union(a, b: Interval): Interval =
  Interval(lo: min(a.lo, b.lo), hi: max(a.hi, b.hi))

proc len(i: Interval): int =
  i.hi - i.lo + 1

proc part1*(input: string): int =
  let (sensors, bs) = input.parse
  let y = 2000000
  var intervals = newSeq[Interval]()
  for sensor in sensors:
    let diff = sensor.dist - abs(sensor.pos.y - y)
    if diff < 0: continue
    intervals.add Interval(lo: sensor.pos.x - diff, hi: sensor.pos.x + diff)
  intervals = intervals.sortedByIt(it.lo)
  intervals = intervals.foldl(if intersects(a[^1], b): a[0..^2] & @[union(a[^1], b)]
                              else: a & @[b], @[intervals[0]])
  for interval in intervals:
    result += interval.len
  for x in bs:
    for i in intervals:
      if x in i.lo..i.hi:
        dec result

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
