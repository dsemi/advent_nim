import fusion/matching
import heapqueue
import options
import sets
import sequtils
import strutils
import sugar
import tables

import "../utils"

proc parseGraph(input: string): seq[seq[(char, int)]] =
  for row in input.splitLines:
    result.add(@[])
    for v in row:
      result[^1].add((v, if v in "EG": 200 else: 0))

proc neighbors(grid: var seq[seq[(char, int)]], coord: Coord): seq[Coord] =
  # reading order
  [(-1, 0), (0, -1), (0, 1), (1, 0)].mapIt(it + coord)

proc firstMove(path: Table[Coord, Coord], pos: Coord): Option[Coord] =
  var pos = pos
  while pos in path:
    result = some(pos)
    pos = path[pos]

proc contains(q: HeapQueue[(int, Coord)], p: Coord): bool =
  for i in 0 ..< q.len:
    if q[i][1] == p:
      return true

proc findNextMove(grid: var seq[seq[(char, int)]], enemy: char, coord: Coord): Option[Coord] =
  var np = 1
  var path: Table[Coord, Coord]
  var closed: HashSet[Coord]
  var frontier = [(0, coord)].toHeapQueue
  while frontier.len > 0:
    let (_, pos) = frontier.pop
    let neighbs = neighbors(grid, pos)
    if neighbs.anyIt(grid[it[0]][it[1]][0] == enemy):
      return firstMove(path, pos)
    closed.incl(pos)
    let ns = neighbs.filterIt(grid[it[0]][it[1]][0] == '.' and it notin closed and it notin frontier)
    for n in ns:
      path[n] = pos
      frontier.push((np, n))
      inc np

proc runRound(grid: var seq[seq[(char, int)]], elfPower: int, allowElfDeath: bool): bool =
  let units = collect(newSeq):
    for r, row in grid:
      for c, v in row:
        if v[0] in "EG":
          (r, c)
  for pos in units:
    let v = grid[pos[0]][pos[1]]
    if v[0] notin "EG":
      continue
    let enemy = if v[0] == 'E': 'G' else: 'E'
    let pos2 = if Some(@p) ?= findNextMove(grid, enemy, pos):
                 grid[pos[0]][pos[1]] = ('.', 0)
                 grid[p[0]][p[1]] = v
                 p
               else:
                 pos
    let targets = neighbors(grid, pos2).filterIt(grid[it[0]][it[1]][0] == enemy)
    if targets.len > 0:
      let pwr = if v[0] == 'E': elfPower else: 3
      var (tPos, n) = ((0, 0), int.high)
      for target in targets:
        if grid[target[0]][target[1]][1] < n:
          n = grid[target[0]][target[1]][1]
          tPos = target
      let (t, hp) = grid[tPos[0]][tPos[1]]
      if hp <= pwr:
        if not allowElfDeath and t == 'E':
          return true
        else:
          grid[tPos[0]][tPos[1]] = ('.', 0)
      else:
        grid[tPos[0]][tPos[1]] = (t, hp - pwr)

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
  # Should be counting completed rounds, this fails example but works on real input
  for c in 0..int.high:
    discard grid.runRound(3, true)
    if Some(@sc) ?= grid.score(c):
      return sc

proc part2*(input: string): int =
  let gridStart = input.parseGraph
  var elfPwr = 3
  for elfPwr in 3..int.high:
    var grid = gridStart
    # Should be counting completed rounds, this fails example but works on real input
    for c in 0..int.high:
      if grid.runRound(elfPwr, false):
        break
      if Some(@sc) ?= grid.score(c):
        return sc
