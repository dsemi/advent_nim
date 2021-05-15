import deques
import fusion/matching
import options
import sets
import sequtils
import strutils
import sugar
import tables

import "../utils"

type Outcome = enum
  Finished, ElfDied, EndedEarly

proc parseGraph(input: string): seq[seq[(char, int)]] =
  for row in input.splitLines:
    result.add(@[])
    for v in row:
      result[^1].add((v, if v in "EG": 200 else: 0))

proc get[T](grid: var seq[seq[T]], pos: Coord): var T {.inline.} =
  grid[pos[0]][pos[1]]

proc neighbors(coord: Coord): seq[Coord] =
  # reading order
  [(-1, 0), (0, -1), (0, 1), (1, 0)].mapIt(it + coord)

proc findNextMove(grid: var seq[seq[(char, int)]], enemy: char, coord: Coord): Option[Coord] =
  var path: Table[Coord, Coord]
  var visited = [coord].toHashSet
  var frontier = [coord].toDeque
  while frontier.len > 0:
    var pos = frontier.popFirst
    let neighbs = pos.neighbors
    if neighbs.anyIt(grid.get(it)[0] == enemy):
      while pos in path:
        result = some(pos)
        pos = path[pos]
      break
    for n in neighbs:
      if grid.get(n)[0] == '.' and n notin visited:
        visited.incl(n)
        path[n] = pos
        frontier.addLast(n)

proc runRound(grid: var seq[seq[(char, int)]], elfPower: int, allowElfDeath: bool): Outcome =
  var elves, goblins: int
  let units = collect(newSeq):
    for r, row in grid:
      for c, v in row:
        if v[0] in "EG":
          if v[0] == 'E': inc elves else: inc goblins
          (r, c)
  for pos in units:
    if elves == 0 or goblins == 0:
      return EndedEarly
    let v = grid.get(pos)
    if v[0] notin "EG":
      continue
    let enemy = if v[0] == 'E': 'G' else: 'E'
    var pos = pos
    if Some(@p) ?= findNextMove(grid, enemy, pos):
      grid.get(pos) = ('.', 0)
      grid.get(p) = v
      pos = p
    let targets = pos.neighbors.filterIt(grid.get(it)[0] == enemy)
    if targets.len > 0:
      let pwr = if v[0] == 'E': elfPower else: 3
      let tPos = targets.foldl(if grid.get(b) < grid.get(a): b else: a)
      let (t, hp) = grid.get(tPos)
      if hp <= pwr:
        if not allowElfDeath and t == 'E':
          return ElfDied
        else:
          if t == 'E': dec elves else: dec goblins
          grid.get(tPos) = ('.', 0)
      else:
        grid.get(tPos) = (t, hp - pwr)

proc score(grid: var seq[seq[(char, int)]], c: int): Option[int] =
  var elves, goblins: bool
  var total = 0
  for row in grid:
    for (t, v) in row:
      if t == 'E':
        elves = true
      elif t == 'G':
        goblins = true
      if elves and goblins:
        return none(int)
      total += v
  return some(c * total)

proc part1*(input: string): int =
  var grid = input.parseGraph
  for c in 0..int.high:
    let res = grid.runRound(3, true)
    if Some(@sc) ?= grid.score(if res == Finished: c+1 else: c):
      return sc

proc part2*(input: string): int =
  let gridStart = input.parseGraph
  for elfPwr in 3..int.high:
    var grid = gridStart
    for c in 0..int.high:
      let res = grid.runRound(elfPwr, false)
      if res == ElfDied:
        break
      if Some(@sc) ?= grid.score(if res == Finished: c+1 else: c):
        return sc
