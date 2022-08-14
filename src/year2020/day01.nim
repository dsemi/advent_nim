import algorithm
import fusion/matching
import options
import sequtils
import strutils

{.experimental: "caseStmtMacros".}

proc solve(input: string, x: int): Option[int] =
  let ns = input.splitLines.map(parseInt).sorted
  proc go(n: int, c: int, xs: openArray[int]): Option[int] =
    if n == 1:
      if xs.binarySearch(c) >= 0:
        return some(c)
    else:
      for x in xs:
        case go(n-1, c-x, xs[xs.upperBound(x) .. ^1])
        of Some(@x2):
          return some(x * x2)
  go(x, 2020, ns)

proc part1*(input: string): Option[int] =
  solve(input, 2)

proc part2*(input: string): Option[int] =
  solve(input, 3)
