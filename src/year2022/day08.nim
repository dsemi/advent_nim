import sequtils
import strutils

type Tree = object
  visibleFromEdge: bool
  scenicScore: int

iterator trees(input: string): Tree =
  let grid = input.splitLines.mapIt(it.mapIt(($it).parseInt.uint8))
  proc walk(val: uint8, iter: iterator: uint8): int =
    for x in iter:
      inc result
      if x >= val:
        break
  for r in grid.low .. grid.high:
    for c in grid[r].low .. grid[r].high:
      var tree = Tree(scenicScore: 1)
      let toEdges = [
        iterator(): uint8 = (for nr in countdown(r-1, grid.low): yield grid[nr][c]),
        iterator(): uint8 = (for nr in countup(r+1, grid.high): yield grid[nr][c]),
        iterator(): uint8 = (for nc in countdown(c-1, grid[r].low): yield grid[r][nc]),
        iterator(): uint8 = (for nc in countup(c+1, grid[r].high): yield grid[r][nc]),
      ]
      for path in toEdges:
        tree.scenicScore *= walk(grid[r][c], path)
        tree.visibleFromEdge = tree.visibleFromEdge or finished(path)
      yield tree

proc part1*(input: string): int =
  for tree in input.trees:
    result += tree.visibleFromEdge.int

proc part2*(input: string): int =
  for tree in input.trees:
    result = max(result, tree.scenicScore)
