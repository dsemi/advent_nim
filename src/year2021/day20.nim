import algorithm
import fusion/matching
import sequtils
import strutils

proc pad(grid: var seq[seq[char]], c: char) =
  grid.insert(newSeqWith(grid[0].len, c), 0)
  grid.add(newSeqWith(grid[0].len, c))
  for row in grid.mitems:
    row.insert(c, 0)
    row.add(c)

proc enhance(grid: var seq[seq[char]], iea: string) =
  grid.pad(grid[0][0])
  var grid2: seq[seq[char]]
  deepCopy(grid2, grid)
  for r in 1 ..< grid.len - 1:
    for c in 1 ..< grid[r].len - 1:
      var n: int
      for dr in [-1, 0, 1]:
        for dc in [-1, 0, 1]:
          n = n shl 1 or int(grid[r+dr][c+dc] == '#')
      grid2[r][c] = iea[n]
  swap(grid, grid2)
  let n = if grid[0][0] == '#': 1 shl 9 - 1 else: 0
  let ch = iea[n]
  let last = grid.len - 1
  for i, row in grid.mpairs:
    row[0] = ch
    row[^1] = ch
    if i == 0 or i == last:
      row.fill(ch)

proc run(input: string, times: int): int =
  [@iea, @img] := input.split("\n\n", 1)
  var im = img.splitlines.mapIt(it.toSeq)
  pad(im, '.')
  for _ in 1..times:
    im.enhance(iea)
  for row in im:
    result += row.count('#')

proc part1*(input: string): int =
  run(input, 2)

proc part2*(input: string): int =
  run(input, 50)
