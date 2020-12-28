import itertools
import sets
import sequtils
import strutils
import sugar
import tables

proc solve(input: string, dim: int = 3): int =
  var onCubes = collect(initHashSet):
    for y, row in toSeq(input.splitlines):
      for x, v in row:
        if v == '#':
          {concat(@[x, y], repeat(0, dim-2))}
  for _ in 1..6:
    var m = initCountTable[seq[int]]()
    for pos in onCubes:
      for neighb in product([-1, 0, 1], repeat=dim):
        let pos2 = pos.zip(neighb).mapIt(it[0] + it[1])
        if pos != pos2:
          m.inc(pos2)
    let s1 = collect(initHashSet):
      for pos in onCubes:
        if m.getOrDefault(pos) in [2, 3]:
          {pos}
    let s2 = collect(initHashSet):
      for pos, v in m.pairs:
        if pos notin onCubes and v == 3:
          {pos}
    onCubes = s1 + s2
  onCubes.len


proc part1*(input: string): int =
  solve(input)

proc part2*(input: string): int =
  solve(input, 4)
