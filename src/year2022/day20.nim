import math
import sequtils
import strutils
import sugar

proc mix(input: string, scale = 1, times = 1): int =
  let ns = input.splitLines.mapIt(it.parseInt * scale)
  var locs = collect(for i in ns.low..ns.high: i)
  let m = locs.len - 1
  let sz = sizeof(typeof(locs[0]))
  for _ in 1..times:
    for i, n in ns:
      let loc = locs.find(i)
      let idx = floorMod(n + loc, m)
      if loc != m:
        moveMem(addr locs[loc], addr locs[loc+1], sz * (m - loc))
      if idx != m:
        moveMem(addr locs[idx+1], addr locs[idx], sz * (m - idx))
      locs[idx] = i
  let z = locs.find(ns.find(0))
  result += ns[locs[floorMod(z + 1000, locs.len)]]
  result += ns[locs[floorMod(z + 2000, locs.len)]]
  result += ns[locs[floorMod(z + 3000, locs.len)]]

proc part1*(input: string): int =
  input.mix

proc part2*(input: string): int =
  input.mix(811589153, 10)
