import deques
import sequtils
import intsets
import strutils
import sugar
import tables

import "../utils"

type Grid = ref object
  arr: seq[char]
  cols: int

proc parseMaze(input: string): Grid =
  var arr: seq[char]
  var cols: int
  for row in input.splitLines:
    cols = row.len
    arr.add(row)
  Grid(arr: arr, cols: cols)

proc distsToKeys(grid: Grid, found: set[char], start: int): seq[(char, int, int)] =
  proc neighbors(node: (int, int)): seq[(int, int)] =
    let (pos, depth) = node
    for d in [-grid.cols, -1, 1, grid.cols]:
      let p2 = pos + d
      let v = grid.arr[p2]
      if v != '#' and (not v.isUpperAscii or v.toLowerAscii in found):
        result.add((p2, depth + 1))

  var visited = [start].toIntSet
  var frontier = (start, 0).neighbors.toDeque
  while frontier.len > 0:
    let (pos, depth) = frontier.popFirst
    if pos in visited:
      continue
    visited.incl(pos)
    let k = grid.arr[pos]
    if k.isLowerAscii and k notin found:
      result.add((k, depth, pos))
    else:
      for neighb in (pos, depth).neighbors:
        frontier.addLast(neighb)

proc put[T](xs: seq[T], i: int, v: T): seq[T] =
  result = xs
  result[i] = v

proc search(grid: Grid, key: char): int =
  let keyPoss = collect(newSeq):
    for i, v in grid.arr:
      if v == key:
        i
  var cache: Table[(seq[int], set[char]), int]
  var cache2: Table[(set[char], int), seq[(char, int, int)]]
  proc d2k(found: set[char], p: int): seq[(char, int, int)] =
    if (found, p) in cache2:
      return cache2[(found, p)]
    result = grid.distsToKeys(found, p)
    cache2[(found, p)] = result
  proc go(starts: seq[int], found: set[char]): int =
    if (starts, found) in cache:
      return cache[(starts, found)]
    result = int.high
    for i, p in starts:
      for (ch, dist, pos) in d2k(found, p):
        let m = dist + go(starts.put(i, pos), found + {ch})
        result = min(result, m)
    if result == int.high:
      result = 0
    cache[(starts, found)] = result
  go(keyPoss, {})

proc part1*(input: string): int =
  var maze = input.parseMaze
  maze.search('@')

proc part2*(input: string): int =
  var maze = input.parseMaze
  for (k, v) in toSeq(countup((39, 39), (41, 41))).zip("@#@###@#@"):
    maze.arr[k[0] * maze.cols + k[1]] = v
  maze.search('@')
