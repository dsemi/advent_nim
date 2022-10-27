import bitops
import fusion/matching
import strutils

proc advance(grid: var openArray[uint8], quads: openArray[uint8], xorIn: uint16, xorOut: uint8, dim: int) =
  var prev: array[100, uint8]
  for r in 0 ..< dim:
    var quad = 0u16
    for c in 0 ..< dim:
      let p = 100*r + c
      quad = (quad and 0x3333) shl 2
      quad = quad or ((uint16(prev[c]) shl 8) or uint16(grid[p]))
      prev[c] = grid[p]
      grid[p] = quads[quad xor xorIn] xor xorOut

proc run(input: string, times: int): int =
  [@iea, @img] := input.split("\n\n", 1)
  var rules: array[2048, uint8]
  var idx = 0
  for c in iea:
    rules[idx] = uint8(c) and 1
    idx = (idx + 0x88 + 1) and 0x777
  var quads: array[65536, uint8]
  for i in quads.low .. quads.high:
    var quad = 0u8
    quad = quad or rules[(i shr 5) and 0x777] shl 5
    quad = quad or rules[(i shr 4) and 0x777] shl 4
    quad = quad or rules[(i shr 1) and 0x777] shl 1
    quad = quad or rules[(i shr 0) and 0x777] shl 0
    quads[i] = quad
  var grid: array[10000, uint8]
  idx = 0
  for r in 0..<50:
    for c in 0..<50:
      var quad = 0u8
      quad = quad or (uint8(img[idx + 0]) and 1) shl 5
      quad = quad or (uint8(img[idx + 1]) and 1) shl 4
      quad = quad or (uint8(img[idx + 101]) and 1) shl 1
      quad = quad or (uint8(img[idx + 102]) and 1) shl 0
      grid[100*r + c] = quad
      idx += 2
    idx += 102
  let xorIn: uint16 = if quads[0] != 0: 0xffff else: 0
  let xorOut: uint8 = if quads[0] != 0: 0x33 else: 0
  for step in countup(0, times-1, 2):
    advance(grid, quads, 0, xorOut, 50+(step+1))
    advance(grid, quads, xorIn, 0, 50+(step+2))
  for v in grid:
    result += v.popcount

proc part1*(input: string): int =
  run(input, 2)

proc part2*(input: string): int =
  run(input, 50)
