import bitops
import sequtils
import sugar
import tables

let rocks: seq[seq[uint8]] = @[
  @[0b0011110'u8],
  @[0b0001000'u8, 0b0011100'u8, 0b0001000'u8],
  @[0b0011100'u8, 0b0000100'u8, 0b0000100'u8],
  @[0b0010000'u8, 0b0010000'u8, 0b0010000'u8, 0b0010000'u8],
  @[0b0011000'u8, 0b0011000'u8],
]

const N = 50

proc topN[T](x: seq[T]): array[N, T] =
  for i, v in x[max(0, x.len - N) .. ^1]:
    result[i] = v

proc solve(input: string, lim: int64): int64 =
  var grid = @[0b1111111'u8]
  var k = 0
  var i = 0'i64
  var seen = initTable[(int, int64, array[N, uint8]), (int64, int)]()
  var extra = 0'i64
  proc shift(rock: var seq[uint8], h: int, op: (uint8, uint8) -> uint8, b: int) =
    if rock.anyIt(it.testBit(b)): return
    for j in h .. min(grid.high, h + rock.high):
      if (rock[j-h].op(1) and grid[j]) != 0:
        return
    for row in rock.mitems:
      row = row.op(1)
  proc left(rock: var seq[uint8], h: int) =
    rock.shift(h, (a, b) => a shl b, 6)
  proc right(rock: var seq[uint8], h: int) =
    rock.shift(h, (a, b) => a shr b, 0)
  proc place(rock: openArray[uint8], h: int): bool =
    for j in h .. min(grid.high, h + rock.high):
      if (rock[j-h] and grid[j]) != 0:
        for x in 0..rock.high:
          grid[x+h+1] = grid[x+h+1] or rock[x]
        while grid[^1] == 0:
          discard grid.pop
        return true
  while i < lim:
    var rock = rocks[i mod 5]
    grid.add @[0'u8, 0'u8, 0'u8, 0'u8]
    var h = grid.high
    while not rock.place(h):
      case input[k mod input.len]
      of '<': rock.left(h)
      of '>': rock.right(h)
      else: raiseAssert "Bad input"
      inc k
      dec h
    let state = (k mod input.len, i mod 5, grid.topN)
    if state in seen:
      let (rockN, height) = seen[state]
      let dy = grid.high - height
      let di = i - rockN
      let amt = (lim - i) div di
      extra += amt * dy
      i += amt * di
    seen[state] = (i, grid.high)
    inc i
  grid.high.int64 + extra

proc part1*(input: string): int64 =
  input.solve(2022)

proc part2*(input: string): int64 =
  input.solve(1000000000000)
