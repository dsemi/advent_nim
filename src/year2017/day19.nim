import sequtils
import strutils
import tables

import "../utils"

proc parseGrid(input: string): Table[Coord, char] =
  for r, line in toSeq(input.splitLines):
    for c, v in line:
      if v != ' ':
        result[(r, c)] = v

const
  left = (0, 1)
  right = (0, -1)

proc turn(grid: Table[Coord, char], dir: Coord, pos: Coord): Coord =
  if left * dir + pos in grid:
    left * dir
  else:
    right * dir

proc followPath(grid: Table[Coord, char]): seq[char] =
  var coord = toSeq(grid.keys).min
  var dir = (1, 0)
  while coord in grid:
    result.add(grid[coord])
    if grid[coord] == '+':
      dir = turn(grid, dir, coord)
    coord += dir

proc part1*(input: string): string =
  input.parseGrid.followPath.filterIt(it notin "|-+").join

proc part2*(input: string): int =
  input.parseGrid.followPath.len
