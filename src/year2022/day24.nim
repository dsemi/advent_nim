import math
import sequtils
import sets
import strutils

import "../utils"

type Valley = ref object
  w, h: int
  blizz: seq[(Coord, Coord)]
  walls: HashSet[Coord]

proc parse(input: string): (Coord, Coord, Valley) =
  let grid = input.splitLines.mapIt(it.toSeq)
  let h = grid.len - 2
  let w = grid[0].len - 2
  let start: Coord = (0, 1)
  let goal: Coord = (grid.high, grid[0].high-1)
  var blizz = newSeq[(Coord, Coord)]()
  var walls = initHashSet[Coord]()
  walls.incl (start.x-1, start.y)
  walls.incl (goal.x+1, goal.y)
  for r, row in grid:
    for c, v in row:
      case v
      of '^': blizz.add ((r, c), (-1, 0))
      of 'v': blizz.add ((r, c), (1, 0))
      of '<': blizz.add ((r, c), (0, -1))
      of '>': blizz.add ((r, c), (0, 1))
      of '#': walls.incl (r, c)
      else: discard
  (start, goal, Valley(w: w, h: h, blizz: blizz, walls: walls))

proc shortestPath(v: var Valley, start, goal: Coord): int =
  var edges = [start].toHashSet
  while goal notin edges:
    inc result
    var nextBlizz = newSeq[(Coord, Coord)]()
    var blizzSet = initHashSet[Coord]()
    for pos, d in v.blizz.items:
      let pos2: Coord = (floorMod(pos.x+d.x-1, v.h)+1, floorMod(pos.y+d.y-1, v.w)+1)
      nextBlizz.add (pos2, d)
      blizzSet.incl pos2
    v.blizz = nextBlizz
    var nextEdges = initHashSet[Coord]()
    for p in edges:
      if p notin v.walls and p notin blizzSet:
        nextEdges.incl p
      for d in [(0, -1), (0, 1), (1, 0), (-1, 0)]:
        let p2 = p + d
        if p2 notin v.walls and p2 notin blizzSet:
          nextEdges.incl p2
    edges = nextEdges

proc part1*(input: string): int =
  var (start, goal, valley) = input.parse
  valley.shortestPath(start, goal)

proc part2*(input: string): int =
  var (start, goal, valley) = input.parse
  result += valley.shortestPath(start, goal)
  result += valley.shortestPath(goal, start)
  result += valley.shortestPath(start, goal)
