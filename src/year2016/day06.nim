import sequtils
import strutils
import tables

import "../utils"

proc part1*(input: string): string =
  input.splitLines.mapIt(toSeq(it)).transpose.mapIt(toCountTable(it).largest.key).join

proc part2*(input: string): string =
  input.splitLines.mapIt(toSeq(it)).transpose.mapIt(toCountTable(it).smallest.key).join
