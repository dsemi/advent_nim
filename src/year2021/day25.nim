import sequtils
import strutils

proc part1*(input: string): int =
  var grid = input.splitlines.mapIt(it.toSeq)
  var changed = true
  var grid2: seq[seq[char]]
  while changed:
    changed = false
    deepCopy(grid2, grid)
    for r in 0 ..< grid.len:
      for c in 0 ..< grid[r].len:
        if grid2[r][c] == '>':
          let n = (c + 1) mod grid[r].len
          if grid2[r][n] == '.':
            changed = true
            grid[r][c] = '.'
            grid[r][n] = '>'
    deepCopy(grid2, grid)
    for r in 0 ..< grid.len:
      for c in 0 ..< grid[r].len:
        if grid2[r][c] == 'v':
          let n = (r + 1) mod grid.len
          if grid2[n][c] == '.':
            changed = true
            grid[r][c] = '.'
            grid[n][c] = 'v'
    inc result

proc part2*(input: string): string =
  " "
