import sequtils
import strutils

import "assembunny"
import "day08" as d8

proc part1*(input: string): int =
  for i in 0..int.high:
    var prog = parseInstrs(input)
    prog.reg['a'] = i
    var x = 0
    var n = 0
    for o in runWithOutput(prog):
      if o != x:
        break
      if n == 10:
        return i
      x = x xor 1
      inc n

proc part2*(_: string): string =
  var prog = parseInstrs(readFile("inputs/2016/bonuschallenge.txt").strip)
  let output = toSeq(runWithOutput(prog))
  d8.part2(output.mapIt(it.chr).join[0..^2])
