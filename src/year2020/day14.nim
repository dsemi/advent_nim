import itertools
import sequtils
import strscans
import strutils
import sugar
import tables

iterator parse(input: string): (string, int, int) =
  var mask: string
  for line in input.splitlines:
    var r, v: int
    if line.scanf("mem[$i] = $i", r, v):
      yield (mask, r, v)
    else:
      mask = line.split()[^1]

proc applyMask(mask: string, v: int): int =
  let mask0s = mask.replace('X', '1').parseBinInt
  let mask1s = mask.replace('X', '0').parseBinInt
  v and mask0s or mask1s

proc part1*(input: string): int =
  var m = initTable[int, int]()
  for (mask, r, v) in parse(input):
    m[r] = applyMask(mask, v)
  for v in m.values:
    result += v

proc part2*(input: string): int =
  var m = initTable[int, int]()
  for (mask, r, v) in parse(input):
    let mask1s = mask.replace('X', '0').parseBinInt
    let r = r or mask1s
    let xs = collect(newSeq):
      for i, x in mask:
        if x == 'X':
          i
    for p in product(['0', '1'], repeat=xs.len):
      var r2 = r
      for (i, x) in xs.zip(p):
        if x == '0':
          r2 = r2 and not (1 shl (35-i))
        else:
          r2 = r2 or (1 shl (35-i))
      m[r2] = v
  for v in m.values:
    result += v
