import strutils

const HEIGHT = 137

type Cucumbers = object
  c: array[HEIGHT, array[4, uint64]]

proc `or`(a, b: Cucumbers): Cucumbers =
  for r in 0..<HEIGHT:
    for i in 0..3:
      result.c[r][i] = a.c[r][i] or b.c[r][i]

proc `and`(a, b: Cucumbers): Cucumbers =
  for r in 0..<HEIGHT:
    for i in 0..3:
      result.c[r][i] = a.c[r][i] and b.c[r][i]

proc `xor`(a, b: Cucumbers): Cucumbers =
  for r in 0..<HEIGHT:
    for i in 0..3:
      result.c[r][i] = a.c[r][i] xor b.c[r][i]

proc shiftUp(a: Cucumbers): Cucumbers =
  result.c[HEIGHT-1] = a.c[0]
  for r in 1..<HEIGHT:
    result.c[r-1] = a.c[r]

proc shiftDown(a: Cucumbers): Cucumbers =
  result.c[0] = a.c[HEIGHT-1]
  for r in 1..<HEIGHT:
    result.c[r] = a.c[r-1]

proc shiftLeft(a: Cucumbers): Cucumbers =
  for r in 0..<HEIGHT:
    result.c[r][0] = (a.c[r][0] shr 1) or (a.c[r][1] shl 63)
    result.c[r][1] = (a.c[r][1] shr 1) or (a.c[r][2] shl 63)
    result.c[r][2] = (a.c[r][2] shr 1) or (a.c[r][0] shl 10)
    result.c[r][2] = result.c[r][2] and 0x7ff
    result.c[r][3] = 0

proc shiftRight(a: Cucumbers): Cucumbers =
  for r in 0..<HEIGHT:
    result.c[r][0] = (a.c[r][0] shl 1) or (a.c[r][2] shr 10)
    result.c[r][1] = (a.c[r][1] shl 1) or (a.c[r][0] shr 63)
    result.c[r][2] = (a.c[r][2] shl 1) or (a.c[r][1] shr 63)
    result.c[r][2] = result.c[r][2] and 0x7ff
    result.c[r][3] = 0

proc advanceRight(d, r: Cucumbers): Cucumbers =
  let res = r.shiftRight
  let blocked = res and (d or r)
  (res xor blocked) or blocked.shiftLeft

proc advanceDown(d, r: Cucumbers): Cucumbers =
  let res = d.shiftDown
  let blocked = res and (d or r)
  (res xor blocked) or blocked.shiftUp

proc toMask(inp: string, dMask, rMask: var uint64) =
  for i, c in inp:
    dMask = dMask or (uint64(c == 'v') shl i)
    rMask = rMask or (uint64(c == '>') shl i)

proc part1*(input: string): int =
  var d: Cucumbers
  var r: Cucumbers
  for i, line in pairs(input.splitLines):
    toMask(line[0   ..<  64], d.c[i][0], r.c[i][0])
    toMask(line[64  ..< 128], d.c[i][1], r.c[i][1])
    toMask(line[128 ..< 139], d.c[i][2], r.c[i][2])
  for cnt in 1..int.high:
    let nextR = advanceRight(d, r)
    let done = nextR == r
    r = nextR
    let nextD = advanceDown(d, r)
    if done and nextD == d:
      return cnt
    d = nextD

proc part2*(input: string): string =
  " "
