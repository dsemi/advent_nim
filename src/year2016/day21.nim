import algorithm
import fusion/matching
import math
import strutils

{.experimental: "caseStmtMacros".}

proc swap(s: var string, i, j: int) =
  swap(s[i], s[j])

proc rotate(s: var string, i: int) =
  s = s[i..<s.len] & s[0..<i]

proc rotChrIdx(i: int): int =
  if i >= 4: i + 2 else: i + 1

proc move(s: var string, i, j: int) =
  let c = s[i]
  s.delete(i, i)
  s.insert($c, j)

proc runProgram(input: string, instrs: seq[string], invert: bool = false): string =
  result = input
  for line in instrs:
    case line.splitWhitespace:
      of ["swap", "position", @x, "with", "position", @y]:
        result.swap(x.parseInt, y.parseInt)
      of ["swap", "letter", @a, "with", "letter", @b]:
        result.swap(result.find(a), result.find(b))
      of ["rotate", "right", @x, _]:
        if invert:
          result.rotate(x.parseInt)
        else:
          result.rotate(result.len - x.parseInt)
      of ["rotate", "left", @x, _]:
        if invert:
          result.rotate(result.len - x.parseInt)
        else:
          result.rotate(x.parseInt)
      of ["rotate", "based", "on", "position", "of", "letter", @c]:
        if invert:
          for i in 0..int.high:
            if rotChrIdx(result.find(c)) == i:
              break
            result.rotate(1)
        else:
          let i = floorMod(result.len - rotChrIdx(result.find(c)), result.len)
          result.rotate(i)
      of ["reverse", "positions", @x, "through", @y]:
        result.reverse(x.parseInt, y.parseInt)
      of ["move", "position", @x, "to", "position", @y]:
        if invert:
          result.move(y.parseInt, x.parseInt)
        else:
          result.move(x.parseInt, y.parseInt)
      else:
        raiseAssert "Parse error: " & line

proc part1*(input: string): string =
  runProgram("abcdefgh", input.splitLines)

proc part2*(input: string): string =
  runProgram("fbgdceah", input.splitLines.reversed, invert = true)
