import sequtils
import std/enumerate
import strutils

import "../utils"

const sz = 2500

const dirs = [-sz - 1, -sz, -sz + 1, -1, 1, sz - 1, sz, sz + 1]

const propDirs = [
  [-sz - 1, -sz, -sz + 1],
  [sz - 1,   sz,  sz + 1],
  [-sz - 1, -1,  sz - 1],
  [-sz + 1, 1,  sz + 1],
]

type Elf = ref object
  pos, prop: int

proc parse(input: string): seq[Elf] =
  for y, line in enumerate(input.splitLines):
    for x, v in line:
      if v == '#':
        result.add Elf(pos: (y + sz div 2)*sz + x + sz div 2, prop: int.low)

iterator steps(elves: var seq[Elf]): bool =
  var grid = newSeq[Elf](sz*sz)
  var props = newSeq[int](sz*sz)
  for elf in elves:
    grid[elf.pos] = elf
  for dir in 0..int.high:
    for elf in elves:
      if dirs.anyIt(grid[elf.pos + it] != nil):
        for i in 0..3:
          let prop = propDirs[(dir+i) mod 4]
          if grid[elf.pos + prop[0]] == nil and
             grid[elf.pos + prop[1]] == nil and
             grid[elf.pos + prop[2]] == nil:
            elf.prop = elf.pos + prop[1]
            props[elf.prop] += 1
            break
    var moved = false
    for elf in elves:
      if elf.prop != int.low:
        if props[elf.prop] == 1:
          moved = true
          grid[elf.pos] = nil
          grid[elf.prop] = elf
          elf.pos = elf.prop
        props[elf.prop] = 0
        elf.prop = int.low
    yield moved

proc part1*(input: string): int =
  var elves = input.parse
  for d, _ in enumerate(1, elves.steps):
    if d == 10:
      var minC = (int.high, int.high)
      var maxC = (int.low, int.low)
      for elf in elves:
        minC = min(minC, (elf.pos mod sz, elf.pos div sz))
        maxC = max(maxC, (elf.pos mod sz + 1, elf.pos div sz + 1))
      return prod(maxC - minC) - elves.len

proc part2*(input: string): int =
  var elves = input.parse
  for d, b in enumerate(1, elves.steps):
    if not b:
      return d
