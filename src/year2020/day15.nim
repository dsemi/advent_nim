import std/packedsets
import strutils

proc exchange[T](a: var T, b: T): T {.inline.} =
  result = a
  a = b

proc solve(n: uint32, input: string): uint32 =
  var m = newSeq[uint32](n)
  var filter = initPackedSet[uint32]()
  var j = 1u32
  for v in input.split(','):
    let k = v.parseUint.uint32
    m[k] = j
    filter.incl(k)
    j += 1
  for i in j ..< n:
    if result < i shr 6:
      result = exchange(m[result], i)
      if result != 0:
        result = i - result
    elif filter.containsOrIncl(result):
      result = i - exchange(m[result], i)
    else:
      m[result] = i
      result = 0

proc part1*(input: string): uint32 =
  solve(2020, input)

proc part2*(input: string): uint32 =
  solve(30_000_000, input)
