import std/algorithm
import std/sequtils
import std/strutils
import std/sugar

proc extrapolate(ns: var seq[int]): int =
  if ns.allIt(it == 0):
    return 0
  result += ns[^1]
  for i in 0 ..< ns.high:
    ns[i] = ns[i + 1] - ns[i]
  ns.setLen(ns.len - 1)
  result += ns.extrapolate

proc solve(input: string, p2: bool): int =
  var vals = collect:
    for line in input.splitLines:
      collect:
        for n in line.splitWhitespace:
          n.parseInt
  for row in vals.mitems:
    if p2:
      row.reverse
    result += row.extrapolate

proc part1*(input: string): int =
  solve(input, false)

proc part2*(input: string): int =
  solve(input, true)
