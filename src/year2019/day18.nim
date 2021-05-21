import deques
import sequtils
import sets
import strutils
import sugar
import tables

import "../utils"

proc parseMaze(input: string): seq[seq[char]] =
  for row in input.splitLines:
    result.add(toSeq(row))

proc get[T](grid: var seq[seq[T]], coord: Coord): var T =
  grid[coord[0]][coord[1]]

proc get[T](grid: seq[seq[T]], coord: Coord): T =
  grid[coord[0]][coord[1]]

proc distsToKeys(grid: seq[seq[char]], found: set[char], start: Coord): seq[(char, (int, Coord))] =
  proc neighbors(node: (Coord, int)): seq[(Coord, int)] =
    let (pos, depth) = node
    for d in [(0, -1), (0, 1), (-1, 0), (1, 0)]:
      let p2 = pos + d
      let v = grid.get(p2)
      if v != '#' and (not v.isUpperAscii or v.toLowerAscii in found):
        result.add((p2, depth + 1))

  var visited = [start].toHashSet
  var frontier = (start, 0).neighbors.toDeque
  while frontier.len > 0:
    let (pos, depth) = frontier.popFirst
    if pos in visited:
      continue
    visited.incl(pos)
    let k = grid.get(pos)
    if k.isLowerAscii and k notin found:
      result.add((k, (depth, pos)))
    else:
      for neighb in (pos, depth).neighbors:
        frontier.addLast(neighb)

proc set[T](xs: seq[T], i: int, v: T): seq[T] =
  result = xs
  result[i] = v

proc search(grid: seq[seq[char]], key: char): int =
  let keyPoss = collect(newSeq):
    for i, row in grid:
      for j, v in row:
        if v == key:
          (i, j)
  # Why can't I just declare the type here? Table[(seq[Coord], set[char]), int]
  var cache = {(@[(0, 0)], {'a'}): 0}.toTable
  proc go(starts: seq[Coord], found: set[char]): int =
    if (starts, found) in cache:
      return cache[(starts, found)]
    result = int.high
    for i, p in starts:
      for (ch, snd) in distsToKeys(grid, found, p):
        let (dist, pos) = snd
        let m = dist + go(starts.set(i, pos), found + {ch})
        result = min(result, m)
    if result == int.high:
      result = 0
    cache[(starts, found)] = result
  go(keyPoss, {})

proc part1*(input: string): int =
  input.parseMaze.search('@')

proc part2*(input: string): int =
  var maze = input.parseMaze
  for (k, v) in toSeq(countup((39, 39), (41, 41))).zip("@#@###@#@"):
    maze.get(k) = v
  maze.search('@')
