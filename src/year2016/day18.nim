import fusion/matching
import sequtils

{.experimental: "caseStmtMacros".}

proc safeOrTrap(a, b, c: char): char =
  case [a, b, c]:
    of ['^', '^', '.']: '^'
    of ['.', '^', '^']: '^'
    of ['^', '.', '.']: '^'
    of ['.', '.', '^']: '^'
    else: '.'

proc numSafe(n: int, input: string): int =
  var row = toSeq(input)
  for _ in 1..n:
    result += row.count('.')
    var row2 = row
    for i in row.low..row.high:
      row2[i] = safeOrTrap(if i == row.low: '.' else: row[i-1],
                           row[i],
                           if i == row.high: '.' else: row[i+1])
    row = row2

proc part1*(input: string): int =
  numSafe(40, input)

proc part2*(input: string): int =
  numSafe(400000, input)
