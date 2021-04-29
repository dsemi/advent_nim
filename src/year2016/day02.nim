import sequtils
import strutils
import sugar
import tables

import "../utils"

const t = {
  "U": ( 0, -1),
  "D": ( 0,  1),
  "L": (-1,  0),
  "R": ( 1,  0),
}.toTable

proc run(s: string, d: string): string =
  let d = collect(initTable):
    for y, line in toSeq(d.splitlines):
      for x, c in toSeq(line.split(' ')):
        if c != ".":
          {(x, y): c}
  var xy = toSeq(d.keys).filterIt(d[it] == "5")[0]
  let digs = collect(newSeq):
    for line in s.splitlines:
      xy = foldl(line.mapIt($it), if t[b] + a in d: t[b] + a else: a, xy)
      d[xy]
  digs.join("")

proc part1*(input: string): string =
  let d = """
1 2 3
4 5 6
7 8 9"""
  run(input, d)

proc part2*(input: string): string =
  let d = """
. . 1 . .
. 2 3 4 .
5 6 7 8 9
. A B C .
. . D . ."""
  run(input, d)
