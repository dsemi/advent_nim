import strutils

proc countTrees(right: int, down: int, input: string): int64 =
  let grid = input.splitlines
  for y, row in grid:
    if y mod down != 0:
      continue
    let y = y div down
    if row[y * right mod row.len] == '#':
      result += 1

proc part1*(input: string): int64 =
  countTrees(3, 1, input)

proc part2*(input: string): int64 =
  countTrees(1, 1, input) *
  countTrees(3, 1, input) *
  countTrees(5, 1, input) *
  countTrees(7, 1, input) *
  countTrees(1, 2, input)
