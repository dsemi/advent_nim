import re
import sequtils
import sets
import strutils
import sugar
import tables

import "../utils"

let dirs = {
  "e" : (1, -1),
  "se": (0, -1),
  "sw": (-1, 0),
  "w" : (-1, 1),
  "nw": (0, 1),
  "ne": (1, 0),
}.toTable

proc flipTiles(input: string): HashSet[Coord] =
  result = initHashSet[Coord]()
  let m = toSeq(dirs.keys).join("|").re
  for line in input.splitlines:
    var coord = (0, 0)
    for d in findAll(line, m):
      coord += dirs[d]
    result = result -+- toHashSet([coord])

proc part1*(input: string): int =
  flipTiles(input).len

proc part2*(input: string): int =
  var tiles = flipTiles(input)
  for _ in 1..100:
    var adj = newCountTable[Coord]()
    for t in tiles:
      for d in dirs.values:
        adj.inc(t + d)
    tiles = collect(initHashSet):
      for t, v in adj.pairs:
        if (if t in tiles: v != 0 and v <= 2 else: v == 2):
          {t}
  tiles.len
