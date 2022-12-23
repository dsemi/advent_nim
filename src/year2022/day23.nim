import sequtils
import sets
import std/enumerate
import strutils
import sugar

import "../utils"

const dirs = [(-1'i16, 1'i16), (0'i16, 1'i16), (1'i16, 1'i16),
              (-1'i16, 0'i16), (1'i16, 0'i16),
              (-1'i16, -1'i16), (0'i16, -1'i16), (1'i16, -1'i16)]

proc move(elves: HashSet[Coord16], elf: Coord16, dir: int): Coord16 =
  let adjs = collect:
    for d in dirs:
      elf + d notin elves
  if adjs.anyIt(not it):
    let poss = [(adjs[0] and adjs[1] and adjs[2], (elf.x, elf.y+1)),
                (adjs[5] and adjs[6] and adjs[7], (elf.x, elf.y-1)),
                (adjs[0] and adjs[3] and adjs[5], (elf.x-1, elf.y)),
                (adjs[2] and adjs[4] and adjs[7], (elf.x+1, elf.y))]
    for i in 0..3:
      let (avail, elf2) = poss[(dir+i) mod 4]
      if avail:
        return elf2
  elf

iterator steps(input: string): HashSet[Coord16] =
  var elves = initHashSet[Coord16]()
  for r, line in enumerate(input.splitLines):
    for c, v in line:
      if v == '#':
        elves.incl (c.int16, -r.int16)
  var dir = 0
  for _ in 1..int.high:
    var elves2 = elves
    elves.clear
    for elf in elves2:
      let elf2 = move(elves2, elf, dir)
      if elf2 in elves:
        elves.excl elf2
        elves.incl elf
        elves.incl (elf2 - elf).scale(2) + elf
      else:
        elves.incl elf2
    yield elves
    dir = (dir+1) mod 4

proc part1*(input: string): int =
  for d, elves in enumerate(1, input.steps):
    if d == 10:
      var minC = (int16.high, int16.high)
      var maxC = (int16.low, int16.low)
      for elf in elves:
        minC = min(minC, elf)
        maxC = max(maxC, elf + (1'i16, 1'i16))
      return prod(maxC - minC) - elves.len

proc part2*(input: string): int =
  var prev: HashSet[Coord16]
  for d, elves in enumerate(1, input.steps):
    if prev == elves:
      return d
    prev = elves
