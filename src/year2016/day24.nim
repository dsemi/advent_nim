import algorithm
import math
import sequtils
import strutils
import sugar
import tables

import "../utils"

proc parseGrid(input: string): seq[seq[char]] =
  input.splitLines.mapIt(toSeq(it))

proc findAllDistances(grid: seq[seq[char]], ns: seq[(Coord, char)]): Table[(char, char), int] =
  proc neighbors(xy: Coord): iterator: Coord =
    return iterator(): Coord =
      for d in [(1, 0), (-1, 0), (0, 1), (0, -1)]:
        let c = xy + d
        if c[0] >= grid.low and c[0] < grid.len and
           c[1] >= grid[c[0]].low and c[1] < grid[c[0]].len and
           grid[c[0]][c[1]] != '#':
          yield c
  for (p1, n1) in ns:
    for (p2, n2) in ns:
      if p1 == p2:
        result[(n1, n2)] = 0
        continue
      for (d, n) in bfs(p1, neighbors):
        if n == p2:
          result[(n1, n2)] = d
          break

proc allPathsAndDistanceMap(grid: seq[seq[char]]): (seq[seq[char]], Table[(char, char), int]) =
  var pts = collect(newSeq):
    for r in grid.low..grid.high:
      for c in grid[r].low..grid[r].high:
        if grid[r][c].isDigit:
          ((r, c), grid[r][c])
  pts = pts.sortedByIt(it[1])
  let start = pts[0][1]
  var perms = pts[1..^1].mapIt(it[1])
  var allPaths = @[perms]
  while perms.nextPermutation():
    allPaths.add(perms)
  (allPaths.mapIt(@[start] & it), findAllDistances(grid, pts))

proc minPathLen(dists: Table[(char, char), int], allPaths: seq[seq[char]]): int =
  allPaths.map((xs) => xs.zip(xs[1..^1]).mapIt(dists[it]).sum).min

proc part1*(input: string): int =
  let (allPaths, distMap) = allPathsAndDistanceMap(parseGrid(input))
  minPathLen(distMap, allPaths)

proc part2*(input: string): int =
  let (allPaths, distMap) = allPathsAndDistanceMap(parseGrid(input))
  minPathLen(distMap, allPaths.mapIt(it & @['0']))
