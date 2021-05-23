import nre
import sequtils
import strutils

import "intcode"

const instrs = [
  "north",
  "east",
  "take astrolabe",
  "south",
  "take space law space brochure",
  "north",
  "west",
  "north",
  "north",
  "north",
  "north",
  "take weather machine",
  "north",
  "take antenna",
  "west",
  "south\n" ,
].join("\n")

proc part1*(input: string): string =
  var prog = input.parse
  prog.send(instrs.mapIt(it.ord))
  prog.run
  var s = ""
  for v in prog.recv:
    s &= v.chr
  for m in s.findIter(re"\d+"):
    result = m.match

proc part2*(input: string): string =
  " "
