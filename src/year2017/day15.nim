import fusion/matching
import sequtils
import strutils
import sugar

proc parse(input: string): (int, int) =
  [@a, @b] := input.splitLines.mapIt(it.splitWhitespace[^1].parseInt)
  (a, b)

proc judge(nA, nB: (int) -> int, n: int, gens: (int, int)): int =
  var (a, b) = gens
  for _ in 1..n:
    result += int(uint16(a) == uint16(b))
    a = nA(a)
    b = nB(b)

proc nextA(a: int): int =
  a * 16807 mod 2147483647

proc nextB(b: int): int =
  b * 48271 mod 2147483647

proc part1*(input: string): int =
  judge(nextA, nextB, 40_000_000, parse(input))

proc nextA2(a: int): int =
  result = nextA(a)
  while result mod 4 != 0:
    result = nextA(result)

proc nextB2(b: int): int =
  result = nextB(b)
  while result mod 8 != 0:
    result = nextB(result)

proc part2*(input: string): int =
  judge(nextA2, nextB2, 5_000_000, parse(input))
