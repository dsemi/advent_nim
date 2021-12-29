import algorithm
import math
import sequtils
import strutils

import "../utils.nim"

type
  T = enum
    A, B, C, D, E

  Diagram = object
    stacks: array[9, seq[T]]
    lens: array[9, int]
    done: array[4, bool]

proc `<`(a, b: Diagram): bool =
  false

const DEST: array[T, int] = [1, 3, 5, 7, -1]

proc parse(input: string, p2: bool): Diagram =
  var stacks: array[9, seq[T]]
  var lens = [2, 0, 1, 0, 1, 0, 1, 0, 2]
  var i = 1
  for line in input.splitlines.toSeq.reversed:
    for c in line:
      if c in "ABCD":
        stacks[i].add(parseEnum[T]($c))
        i = (i + 2) mod 8
  if p2:
    stacks[1].insert([D, D], 1)
    stacks[3].insert([B, C], 1)
    stacks[5].insert([A, B], 1)
    stacks[7].insert([C, A], 1)
  for i in DEST[0 ..< ^1]:
    lens[i] = stacks[i].len
  Diagram(stacks: stacks, lens: lens)

proc neighbs(diag: Diagram): seq[(int, Diagram)] =
  for i in 0 ..< diag.stacks.len:
    if diag.stacks[i].len == 0:
      continue
    if i mod 2 == 0:
      let c = diag.stacks[i][^1]
      let t = DEST[c]
      if diag.stacks[t].allIt(it == c) and
         (min(i, t) + 1 ..< max(i, t)).toSeq.filterIt(it mod 2 == 0).allIt(diag.stacks[it].len == 0):
        var next = diag
        var cost = max(i, t) - min(i, t) + next.lens[i] - next.stacks[i].len +
                   next.lens[t] - next.stacks[t].len
        cost *= 10 ^ int(c)
        let v = next.stacks[i].pop
        if next.stacks[i].len != 0 and next.stacks[i][0] == E:
          discard next.stacks[i].pop
        next.stacks[t].add(v)
        if next.stacks[t].len == next.lens[t]:
            next.done[t div 2] = true
        return @[(cost, next)]
    elif not diag.done[i div 2]:
      let c = diag.stacks[i][^1]
      let t = DEST[c]
      if i == t and diag.stacks[i].allIt(it == c):
        continue
      var candidates = countup(0, diag.stacks.len - 1, 2).toSeq
      if diag.stacks[t].allIt(it == c):
        candidates.insert(t)
      for j in candidates:
        if j != i and
           diag.stacks[j].len < diag.lens[j] and
           (min(i, j) + 1 ..< max(i, j)).toSeq.filterIt(it mod 2 == 0).allIt(diag.stacks[it].len == 0):
          var next = diag
          var cost = max(i, j) - min(i, j) + next.lens[i] - next.stacks[i].len +
                     next.lens[j] - next.stacks[j].len + int(j == t)
          cost *= 10 ^ int(c)
          let v = next.stacks[i].pop
          next.stacks[j].add(v)
          if j == t:
            if next.stacks[j].len == next.lens[j]:
              next.done[j div 2] = true
            return @[(cost, next)]
          if j != t and diag.stacks[j].len < diag.lens[j] - 1:
            var next2 = next
            next2.stacks[j].insert(E)
            result.add((cost - 10 ^ int(c), next2))
          result.add((cost, next))

proc part1*(input: string): int =
  for (d, v) in dijkstra(parse(input, false), neighbs):
    if v.done.allIt(it):
      return d

proc part2*(input: string): int =
  for (d, v) in dijkstra(parse(input, true), neighbs):
    if v.done.allIt(it):
      return d
