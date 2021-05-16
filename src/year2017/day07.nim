import fusion/matching
import math
import sequtils
import sets
import strutils
import sugar
import tables

import "../utils"

{.experimental: "caseStmtMacros".}

proc part1*(input: string): string =
  case input.splitLines.mapIt(it.split(" -> ")).transpose
  of [@a, @b]:
    let c = collect(initHashSet):
      for x in b:
        for y in x.split(", "):
          {y}
    var s = a.mapIt(it.splitWhitespace[0]).toHashSet - c
    return s.pop

type Node = tuple
  name: string
  weight: int
  children: seq[string]

proc part2*(input: string): int =
  var m: Table[string, Node]
  for line in input.splitLines:
    case line.split(" -> "):
      of [@nw, @chs]:
        [@n, @w] := nw.split(" (")
        m[n] = (n, w[0..^2].parseInt, chs.split(", "))
      of [@nw]:
        [@n, @w] := nw.split(" (")
        m[n] = (n, w[0..^2].parseInt, @[])

  proc findImbalance(curr: string): (int, bool) =
    let node = m[curr]
    if node.children.len == 0:
      return (node.weight, false)

    let recs = node.children.map(findImbalance)
    for r in recs:
      if r[1]: return r
    let wts = recs.mapIt(it[0])
    let count = wts.toCountTable
    if count.len == 1:
      return (node.weight + wts.sum, false)

    let anomaly = count.smallest[0]
    let expected = count.largest[0]
    for i, v in wts:
      if v == anomaly:
        let ans = expected - anomaly + m[node.children[i]].weight
        return (ans, true)

  let root = part1(input)
  findImbalance(root)[0]
