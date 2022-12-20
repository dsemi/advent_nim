import math
import sequtils
import strutils
import sugar

proc part1*(input: string): string =
  var ns = input.mapIt(($it).parseInt)
  for _ in 1..100:
    for (n, x) in ns.mpairs:
      var pos = 0
      for i in countup(n, ns.len-1, (n+1)*4):
        pos += ns[i ..< min(ns.len, i + n + 1)].sum
      var neg = 0
      for i in countup(n+(n+1)*2, ns.len-1, (n+1)*4):
        neg += ns[i ..< min(ns.len, i + n + 1)].sum
      x = abs(pos - neg) mod 10
  ns[0..7].mapIt($it).join

const PASCAL_PERIOD = 16000

proc makePascal(): array[PASCAL_PERIOD, int32] =
  var i = 0
  var v = 1i32
  while i < PASCAL_PERIOD:
    result[i] = v
    i += 1
    v = (v + 1) mod 10
  var p = 2
  while p < 100:
    result[0] = 1
    var index = 1
    while index < PASCAL_PERIOD:
      result[index] = (result[index - 1] + result[index]) mod 10
      index += 1
    p += 1

proc part2*(input: string): string =
  let offset = input[0..6].parseInt
  let ns = input.mapIt(($it).parseInt)
  doAssert offset > ns.len * 10000 div 2, "Offset is not large enough"
  let pascalDiag = makePascal()

  let nLen = ns.len
  let ds = collect(newSeq):
    for n in offset ..< offset+nLen:
      ns[n mod nLen]
  let jointCycle = lcm(PASCAL_PERIOD, nLen)
  let totLen = nLen * 10000 - offset
  let numCycles = totLen div jointCycle
  let ans = collect(newSeq):
    for i in 0..7:
      var sumFirst = 0
      var idx = 0
      for j in i ..< i+jointCycle:
        sumFirst += pascalDiag[idx mod PASCAL_PERIOD] * ds[j mod ds.len]
        idx += 1
      var sumLast = 0
      idx = 0
      for j in i + numCycles*jointCycle ..< totLen:
        sumLast += pascalDiag[idx mod PASCAL_PERIOD] * ds[j mod ds.len]
        idx += 1
      (sumFirst * numCycles + sumLast) mod 10
  ans.mapIt($it).join
