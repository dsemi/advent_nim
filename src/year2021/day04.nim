import fusion/matching
import math
import sequtils
import strutils
import sugar

proc isWinner(board: seq[seq[uint8]], ns: set[uint8]): bool =
  for i in 0..<board.len:
    var all1, all2 = true
    for j in 0..<board.len:
      all1 = all1 and board[i][j] in ns
      all2 = all2 and board[j][i] in ns
    if all1 or all2:
      return true

iterator winners(s: string): int =
  [@nums, all @bds] := s.split("\n\n")
  var boards = collect(newSeq):
    for board in bds:
      collect(newSeq):
        for row in board.splitlines:
          collect(newSeq):
            for v in row.splitWhitespace:
              uint8(v.parseUInt)
  var ns: set[uint8]
  for n in nums.split(',').map(parseInt):
    ns.incl(uint8(n))
    var winners: seq[int]
    boards.keepIf(proc(board: seq[seq[uint8]]): bool =
                      if is_winner(board, ns):
                        winners.add(board.map((row) => row.mapIt(if it notin ns: int(it) else: 0).sum).sum)
                        return false
                      return true)
    for w in winners:
      yield w*n

proc part1*(input: string): int =
  for x in winners(input):
    return x

proc part2*(input: string): int =
  for x in winners(input):
    result = x
