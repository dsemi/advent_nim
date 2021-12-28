import fusion/matching
import strscans
import strutils
import tables

proc nums(): iterator(): int =
  return iterator(): int =
    while true:
      for i in 1..100:
        yield i

proc part1*(input: string): int =
  [@a, @b] := input.split('\n', 1)
  var p1, p2: int
  doAssert a.scanf("Player 1 starting position: $i", p1)
  doAssert b.scanf("Player 2 starting position: $i", p2)
  p1 -= 1
  p2 -= 1
  let gen = nums()
  var p1Score, p2Score, n: int
  while p2Score < 1000:
    p1 = (p1 + gen() + gen() + gen()) mod 10
    p1Score += p1 + 1
    n += 3
    swap(p1, p2)
    swap(p1Score, p2Score)
  min(p1Score, p2Score) * n


const PROBS = [(3, 1), (4, 3), (5, 6), (6, 7), (7, 6), (8, 3), (9, 1)]

var cache: Table[(int, int, int, int), (int, int)]

proc solve(p1, p2, s1, s2: int): (int, int) =
  if s1 >= 21:
    return (1, 0)
  if s2 >= 21:
    return (0, 1)
  if (p1, p2, s1, s2) in cache:
    return cache[(p1, p2, s1, s2)]
  for (d, n) in PROBS:
    let newP1 = (p1 + d) mod 10
    let (x1, y1) = solve(p2, newP1, s2, s1 + newP1 + 1)
    result = (result[0] + n * y1, result[1] + n * x1)
  cache[(p1, p2, s1, s2)] = result

proc part2*(input: string): int =
  [@a, @b] := input.split('\n', 1)
  var p1, p2: int
  doAssert a.scanf("Player 1 starting position: $i", p1)
  doAssert b.scanf("Player 2 starting position: $i", p2)
  let (x, y) = solve(p1 - 1, p2 - 1, 0, 0)
  max(x, y)
