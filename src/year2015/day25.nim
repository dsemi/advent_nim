import sequtils
import strutils
import re
import unpack

import "../utils"

proc part1*(input: string): int =
  [r, c] <- findAll(input, re"\d+").map(parseInt)
  let n = r + c - 1
  let index = n * (n - 1) div 2 + c - 1
  powMod(252533, index, 33554393) * 20151125 mod 33554393

proc part2*(input: string): string =
  nil
