import sequtils
import strutils

import "../utils"

proc solve(input: string, sts: set[char]): int =
  var grid = input.splitLines.mapIt(toSeq(it))
  var starts = newSeq[Coord]()
  var done: Coord
  for r, row in grid.mpairs:
    for c, v in row.mpairs:
      if v in sts: starts.add (r, c)
      if v == 'S': v = 'a'
      elif v == 'E':
        done = (r, c)
        v = 'z'

  proc neighbors(pos: Coord): iterator: Coord =
    return iterator(): Coord =
      let lim = (grid[pos].ord + 1).chr
      for d in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
        let pos2 = d + pos
        if pos2.x in grid.low..grid.high and
           pos2.y in grid[0].low..grid[0].high and
           grid[pos2] <= lim:
          yield pos2

  for (d, p) in bfsM(starts, neighbors):
    if p == done:
      return d

proc part1*(input: string): int =
  input.solve({'S'})

proc part2*(input: string): int =
  input.solve({'S', 'a'})
