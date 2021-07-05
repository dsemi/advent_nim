import math
import sequtils
import strutils

proc dragonChecksum(desiredLen: int, input: string): string =
  let sz = block:
             var x = desiredLen
             while x mod 2 == 0:
               x = x div 2
             desiredLen div x
  var ns = input.mapIt(($it).parseInt)
  while ns.len < desiredLen:
    let c = ns.len
    ns.add(0)
    for i in countdown(c-1, 0):
      ns.add(ns[i] xor 1)
  for n in countup(0, desired_len - 1, sz):
    if ns[n..<n+sz].sum mod 2 == 1:
      result &= "0"
    else:
      result &= "1"

proc part1*(input: string): string =
  dragonChecksum(272, input)

proc part2*(input: string): string =
  dragonChecksum(35651584, input)
