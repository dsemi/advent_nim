import strscans
import strutils
import tables

proc solve(input: string, lo, hi: int): int =
  var cubes: CountTable[(int, int, int, int, int, int)]
  for line in input.splitlines:
    var w: string
    var nx0, nx1, ny0, ny1, nz0, nz1: int
    doAssert line.scanf("$* x=$i..$i,y=$i..$i,z=$i..$i", w, nx0, nx1, ny0, ny1, nz0, nz1)
    var update: CountTable[(int, int, int, int, int, int)]
    for k, es in cubes.pairs:
      let (ex0, ex1, ey0, ey1, ez0, ez1) = k
      let (x0, x1) = (max(nx0, ex0), min(nx1, ex1))
      let (y0, y1) = (max(ny0, ey0), min(ny1, ey1))
      let (z0, z1) = (max(nz0, ez0), min(nz1, ez1))
      if x0 <= x1 and y0 <= y1 and z0 <= z1:
        update.inc((x0, x1, y0, y1, z0, z1), -es)
    if w == "on":
      update.inc((nx0, nx1, ny0, ny1, nz0, nz1))
    for k, v in update.pairs:
      cubes.inc(k, v)
  for k, s in cubes:
    let (ox0, ox1, oy0, oy1, oz0, oz1) = k
    let (x0, x1) = (max(lo, ox0), min(hi, ox1))
    let (y0, y1) = (max(lo, oy0), min(hi, oy1))
    let (z0, z1) = (max(lo, oz0), min(hi, oz1))
    result += max(0, x1 - x0 + 1) * max(0, y1 - y0 + 1) * max(0, z1 - z0 + 1) * s

proc part1*(input: string): int =
  solve(input, -50, 50)

proc part2*(input: string): int =
  solve(input, int.low, int.high)
