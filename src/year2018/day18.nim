import sequtils
import strutils
import tables

import "../utils"

proc parseLandscape(input: string): seq[seq[char]] =
  for line in input.splitLines:
    result.add(toSeq(line))

proc neighbors[T](grid: var seq[seq[T]], c: Coord): seq[T] =
  for d in [(-1, 0), (1, 0), (0, -1), (0, 1), (-1, -1), (-1, 1), (1, -1), (1, 1)]:
    let c2 = c + d
    if c2[0] in grid.low..grid.high and c2[1] in grid[c2[0]].low..grid[c2[0]].high:
      result.add(grid[c2[0]][c2[1]])

proc step(grid: var seq[seq[char]]) =
  var counts: seq[seq[CountTable[char]]]
  for r, row in grid:
    counts.add(@[])
    for c, _ in row:
      counts[r].add(grid.neighbors((r, c)).toCountTable)
  for r, row in grid:
    for c, v in row:
      if v == '.' and counts[r][c]['|'] >= 3:
        grid[r][c] = '|'
      elif v == '|' and counts[r][c]['#'] >= 3:
        grid[r][c] = '#'
      elif v == '#' and (counts[r][c]['#'] < 1 or counts[r][c]['|'] < 1):
        grid[r][c] = '.'

proc resourceValue(grid: seq[seq[char]]): int =
  var ws, ls: int
  for row in grid:
    for v in row:
      if v == '|': inc ws
      elif v == '#': inc ls
  ws * ls

proc part1*(input: string): int =
  var grid = input.parseLandscape
  for _ in 1..10:
    grid.step
  grid.resourceValue

proc part2*(input: string): int =
  var n = 1_000_000_000
  var t: Table[int, (int, seq[seq[char]])]
  var grid = input.parseLandscape
  for c in countdown(n, 0):
    let r = grid.resourceValue
    if r in t and t[r][1] == grid:
      let stepsAway = c mod (t[r][0] - c)
      for _ in 1..stepsAway:
        grid.step
      return grid.resourceValue
    else:
      t[r] = (c, grid)
      grid.step
