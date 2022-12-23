import sequtils
import sets
import std/enumerate
import strutils
import tables

import "../utils"

proc adj(elves: HashSet[Coord], pt: Coord): seq[bool] =
  for d in [(-1, 1), (0, 1), (1, 1), (-1, 0), (1, 0), (-1, -1), (0, -1), (1, -1)]:
    result.add pt + d notin elves

iterator steps(input: string): HashSet[Coord] =
  var elves = initHashSet[Coord]()
  for r, line in enumerate(input.splitLines):
    for c, v in line:
      if v == '#':
        elves.incl (c, -r)
  var dir = 0
  for _ in 1..int.high:
    var props = initTable[Coord, seq[Coord]]()
    for elf in elves:
      let adjs = elves.adj(elf)
      if adjs.anyIt(not it):
        let poss = [(adjs[0] and adjs[1] and adjs[2], (elf.x, elf.y+1)),
                    (adjs[5] and adjs[6] and adjs[7], (elf.x, elf.y-1)),
                    (adjs[0] and adjs[3] and adjs[5], (elf.x-1, elf.y)),
                    (adjs[2] and adjs[4] and adjs[7], (elf.x+1, elf.y))]
        for i in 0..3:
          let (avail, elf2) = poss[(dir+i) mod 4]
          if avail:
            props.mgetOrPut(elf2, newSeq[Coord]()).add(elf)
            break
    for elf2, elfs in props.pairs:
      if elfs.len == 1:
        elves.excl elfs[0]
        elves.incl elf2
    yield elves
    dir = (dir+1) mod 4

proc part1*(input: string): int =
  for d, elves in enumerate(1, input.steps):
    if d == 10:
      var minC: Coord = (int.high, int.high)
      var maxC: Coord = (int.low, int.low)
      for elf in elves:
        minC = min(minC, elf)
        maxC = max(maxC, elf + (1, 1))
      return prod(maxC - minC) - elves.len

proc part2*(input: string): int =
  var prev: HashSet[Coord]
  for d, elves in enumerate(1, input.steps):
    if prev == elves:
      return d
    prev = elves
