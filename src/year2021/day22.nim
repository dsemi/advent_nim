import intsets
import strscans
import strutils

import "../utils"

type Cube = object
  axis: array[3, Interval[int64]]

proc volume(a: Cube): int64 =
  result = 1
  for i in a.axis:
    result *= i.len

proc intersects(a, b: Cube): bool =
  result = true
  for i in a.axis.low .. a.axis.high:
    if not a.axis[i].intersects(b.axis[i]):
      return false

proc intersect(a, b: Cube): Cube =
  for i, v in result.axis.mpairs:
    v = a.axis[i].intersect(b.axis[i])

proc solve(input: string, lo, hi: int): int64 =
  let activeCube = Cube(axis: [Interval[int64](lo: lo, hi: hi),
                               Interval[int64](lo: lo, hi: hi),
                               Interval[int64](lo: lo, hi: hi)])
  var cubes = newSeq[Cube]()
  var on = newSeq[bool]()
  for line in input.splitLines:
    var w: string
    var x0, x1, y0, y1, z0, z1: int
    doAssert line.scanf("$* x=$i..$i,y=$i..$i,z=$i..$i", w, x0, x1, y0, y1, z0, z1)
    let cube = Cube(axis: [Interval[int64](lo: x0, hi: x1+1),
                           Interval[int64](lo: y0, hi: y1+1),
                           Interval[int64](lo: z0, hi: z1+1)])
    on.add(w == "on" and cube.intersects(activeCube))
    cubes.add(cube)
  var bs = newSeq[IntSet](cubes.len)
  for i in 0 ..< cubes.len:
    for j in 0 ..< i:
      if cubes[i].intersects(cubes[j]):
        bs[j].incl(i)

  proc intersectVolume(cube: Cube, s: IntSet): int64 =
    result = cube.volume
    for idx in s:
      let common = cube.intersect(cubes[idx])
      let inter = s * bs[idx]
      result -= intersectVolume(common, inter)

  for i in 0 ..< cubes.len:
    if not on[i]:
      continue
    result += intersectVolume(cubes[i], bs[i])

proc part1*(input: string): int64 =
  solve(input, -50, 51)

proc part2*(input: string): int64 =
  solve(input, int.low, int.high)
