import algorithm
import sequtils
import strutils

template yieldSum(xs: seq[int], idxs: seq[bool]): untyped =
  var res: int
  for i, b in idxs.pairs:
    if b:
      res += xs[i]
  yield res

iterator combos(xs: seq[int], n: int): int =
  var idxs = newSeq[bool](xs.len)
  for i in xs.len-n .. idxs.high:
    idxs[i] = true
  yieldSum xs, idxs
  while idxs.nextPermutation:
    yieldSum xs, idxs

iterator allCombos(xs: seq[int]): int =
  for i in 1 .. xs.len:
    var res: int
    for combo in combos(xs, i):
      if combo == 150:
        inc res
    yield res

proc part1*(input: string): int =
  for n in allCombos(input.splitlines.map(parseInt)):
    result += n

proc part2*(input: string): int =
  for n in allCombos(input.splitlines.map(parseInt)):
    if n > 0:
      return n
