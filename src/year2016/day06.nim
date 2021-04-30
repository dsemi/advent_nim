import sequtils
import strutils
import tables

import "../utils"

proc part1*(input: string): string =
  input.splitLines.mapIt(toSeq(it)).transpose.mapIt(it.toCountTable.largest.key).join

proc part2*(input: string): string =
  input.splitLines.mapIt(toSeq(it)).transpose.mapIt(it.toCountTable.smallest.key).join
