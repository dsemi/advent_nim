import algorithm
import bitops
import std/packedsets
import strutils
import sugar

proc parse(input: string): uint64 =
  for row in reversed(input.splitLines):
    for v in row.reversed:
      result = result shl 2 or uint64(v == '#')

const MASK = 0x5555555555555555'u64
proc sacc(x, a: uint64): uint64 =
  ((x and not MASK) or ((x and MASK) + a)) xor (a and x and (x shr 1))

proc evenBits(grid: uint64): uint32 =
  result = uint32(grid or (grid shr 31))
  result = (result and 0x99999999'u32) or (result and 0x22222222'u32) shl 1 or (result and 0x44444444'u32) shr 1
  result = (result and 0xc3c3c3c3'u32) or (result and 0x0c0c0c0c'u32) shl 2 or (result and 0x30303030'u32) shr 2
  result = (result and 0xf00ff00f'u32) or (result and 0x00f000f0'u32) shl 4 or (result and 0x0f000f00'u32) shr 4
  result = (result and 0xff0000ff'u32) or (result and 0x0000ff00'u32) shl 8 or (result and 0x00ff0000'u32) shr 8

proc neighbors4(grid: uint64): uint64 =
  result = sacc(grid shl 10, grid shr 10)
  result = sacc(result, (grid and 0x0ff3fcff3fcff'u64) shl 2)
  result = sacc(result, (grid and 0x3fcff3fcff3fc'u64) shr 2)

proc lifeOrDeath(grid, n, mask: uint64): uint64 =
  let survived = grid and (n and not (n shr 1))
  let born = not grid and (n xor (n shr 1))
  (survived or born) and mask

proc next(grid: uint64): uint64 =
  lifeOrDeath(grid, neighbors4(grid), 0x1555555555555'u64)

proc part1*(input: string): uint32 =
  var planet = input.parse
  var s = PackedSet[uint64]()
  while not s.containsOrIncl(planet):
    planet = planet.next
  planet.evenBits

const UMASK = 0x155'u64
const DMASK = UMASK shl 40
const LMASK = 0x10040100401'u64
const RMASK = LMASK shl 8
const IMASK = 0x404404000'u64
const IUDMASK = 0x400004000'u64
proc step(inner, grid, outer: uint64): uint64 =
  let oud = (uint64.high - ((outer shr 14) and 1) + 1) and UMASK or
            (uint64.high - ((outer shr 34) and 1) + 1) and DMASK
  let olr = (uint64.high - ((outer shr 22) and 1) + 1) and LMASK or
            (uint64.high - ((outer shr 26) and 1) + 1) and RMASK

  let iud = (inner and UMASK) shl 10 or (inner and DMASK) shr 10
  let ilr = (inner and LMASK) shl 2 or (inner and RMASK) shr 2

  var n = neighbors4(grid)
  n = sacc(n, oud)
  n = sacc(n, olr)
  n = sacc(n, (iud or ilr) and IMASK)
  n = sacc(n, (iud shr 2 or ilr shr 10) and IMASK)
  n = sacc(n, (iud shl 2 or ilr shl 10) and IMASK)
  n = sacc(n, ((iud shr 4 and IUDMASK) or ilr shr 20) and IMASK)
  n = sacc(n, ((iud shl 4 and IUDMASK) or ilr shl 20) and IMASK)

  lifeOrDeath(grid, n, 0x1555554555555'u64)

proc part2*(input: string): int =
  var planets = @[0'u64, input.parse, 0]
  for _ in 1..200:
    planets = collect:
      for i in 0..planets.high+2:
        step(if i-2 in planets.low..planets.high: planets[i-2] else: 0,
             if i-1 in planets.low..planets.high: planets[i-1] else: 0,
             if i in planets.low..planets.high: planets[i] else: 0)
  for p in planets:
    result += p.popcount
