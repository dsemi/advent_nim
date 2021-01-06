import strutils
import sets
import tables

import "../utils"

proc parse(input: string): HashSet[Coord] =
  for r, row in pairs(input.splitlines):
    for c, v in row:
      if v == '#':
        result.incl((r, c))

proc step(ons: HashSet[Coord]): HashSet[Coord] =
  var adjs: CountTable[Coord]
  for p in ons:
    for x in [-1, 0, 1]:
      for y in [-1, 0, 1]:
        if (x != 0 or y != 0) and p.x+x >= 0 and p.x+x < 100 and p.y+y >= 0 and p.y+y < 100:
          adjs.inc((p.x+x, p.y+y))
  for p in ons:
    if adjs.getOrDefault(p) in [2, 3]:
      result.incl(p)
  for p, v in adjs.pairs:
    if p notin ons and v == 3:
      result.incl(p)

proc part1*(input: string): int =
  var ons = parse(input)
  for _ in 1..100:
    ons = step(ons)
  ons.len

proc part2*(input: string): int =
  var ons = parse(input) + [(0, 0), (99, 0), (0, 99), (99, 99)].toHashSet
  for _ in 1..100:
    ons = step(ons) + [(0, 0), (99, 0), (0, 99), (99, 99)].toHashSet
  ons.len
