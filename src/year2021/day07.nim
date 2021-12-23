import algorithm
import math
import sequtils
import strutils

proc part1*(input: string): int =
  var ns = input.split(',').map(parseInt)
  ns.sort
  let med = if ns.len mod 2 == 0: (ns[ns.len div 2 - 1] + ns[ns.len div 2]) div 2
            else: ns[ns.len div 2]
  ns.mapIt((it - med).abs).sum

proc g(n: int): int =
  n * (n + 1) div 2

proc part2*(input: string): int =
  let ns = input.split(',').map(parseInt)
  let mean = ns.sum / ns.len
  min(ns.mapIt((it - mean.floor.int).abs.g).sum,
      ns.mapIt((it - mean.ceil.int).abs.g).sum)
