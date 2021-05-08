import sequtils
import strutils
import tables

import "../utils"

proc parseGrid(input: string): Table[Coord, char] =
  for r, line in toSeq(input.splitLines):
    for c, v in line:
      if v != ' ':
        result[(r, c)] = v

proc start(grid: Table[Coord, char]): Coord =
  for (k, v) in grid.pairs:
    if k[0] == 0 and v == '|':
      return k

const
  left = (0, 1)
  right = (0, -1)

proc turn(grid: Table[Coord, char], dir: Coord, pos: Coord): Coord =
  if left * dir + pos in grid:
    left * dir
  else:
    right * dir

proc followPath(grid: Table[Coord, char]): seq[char] =
  var coord = grid.start
  var dir = (1, 0)
  while true:
    let nextCoord = coord + dir
    if nextCoord notin grid:
      if grid[coord] != '+':
        result.add(grid[coord])
        break
      dir = turn(grid, dir, coord)
    else:
      result.add(grid[coord])
      coord = nextCoord

proc part1*(input: string): string =
  input.parseGrid.followPath.filterIt(it notin "|-+").join

proc part2*(input: string): int =
  input.parseGrid.followPath.len
