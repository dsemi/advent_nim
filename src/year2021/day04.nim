import fusion/matching
import sequtils
import strutils

type Board = object
  grid: seq[seq[uint8]]
  done: bool

proc isWinner(board: Board, ns: set[uint8]): bool =
  for i in 0..<board.grid.len:
    var all1, all2 = true
    for j in 0..<board.grid.len:
      all1 = all1 and board.grid[i][j] in ns
      all2 = all2 and board.grid[j][i] in ns
    if all1 or all2:
      return true

proc score(board: Board, ns: set[uint8]): int =
  for row in board.grid:
    for v in row:
      if v notin ns:
        result += int(v)

iterator winners(s: string): int =
  [@nums, all @bds] := s.split("\n\n")
  var boards = bds.mapIt(Board(grid: it.splitLines.mapIt(it.splitWhitespace.mapIt(it.parseUint.uint8))))
  var ns: set[uint8]
  for n in nums.split(',').map(parseInt):
    ns.incl(uint8(n))
    for board in boards.mitems:
      if not board.done and board.isWinner(ns):
        board.done = true
        yield n * board.score(ns)

proc part1*(input: string): int =
  for x in winners(input):
    return x

proc part2*(input: string): int =
  for x in winners(input):
    result = x
