import sequtils
import strutils

type Tree = object
  up: int
  down: int
  left: int
  right: int
  visibleFromEdge: bool

iterator trees(input: string): Tree =
  let grid = input.splitLines.mapIt(it.mapIt(($it).parseInt.uint8))
  template check(x, iter, field, val) =
    var edge = true
    for x in iter:
      inc tree.field
      if val >= grid[r][c]:
        edge = false
        break
    if edge:
      tree.visibleFromEdge = true
  for r in grid.low .. grid.high:
    for c in grid[r].low .. grid[r].high:
      var tree = Tree()
      check(nr, countdown(r-1, grid.low), up, grid[nr][c])
      check(nr, countup(r+1, grid.high), down, grid[nr][c])
      check(nc, countdown(c-1, grid[r].low), left, grid[r][nc])
      check(nc, countup(c+1, grid[r].high), right, grid[r][nc])
      yield tree

proc part1*(input: string): int =
  for tree in input.trees:
    result += tree.visibleFromEdge.int

proc part2*(input: string): int =
  for tree in input.trees:
    result = max(result, tree.up * tree.down * tree.left * tree.right)
