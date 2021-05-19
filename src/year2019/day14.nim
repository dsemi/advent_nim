import fusion/matching
import strutils
import sugar
import tables

type Reactions = Table[string, (int64, seq[(int64, string)])]

proc parseReactions(input: string): Reactions =
  for line in input.splitLines:
    [@ins, @outp] := line.split(" => ")
    let inps = collect(newSeq):
      for inp in ins.split(", "):
        [@n, @elem] := inp.split
        (n.parseBiggestInt, elem)
    [@n, @elem] := outp.split
    result[elem] = (n.parseBiggestInt, inps)

proc numOre(reactions: Reactions, n: int64): int64 =
  var ore: int64
  var surplus: Table[string, int64]
  proc go(k: string, c: int64) =
    if k in reactions:
      let (n, chems) = reactions[k]
      let (q, r) = (c div n, c mod n)
      for (a, chem) in chems:
        let amt = a * (if r != 0: q+1 else: q)
        let val = surplus.getOrDefault(chem, 0)
        surplus[chem] = max(0, val - amt)
        if amt > val:
          go(chem, amt - val)
      if r != 0:
        surplus[k] += n - r
    else:
      ore += c
  go("FUEL", n)
  ore

proc part1*(input: string): int64 =
  input.parseReactions.numOre(1)

const trillion = 1_000_000_000_000

proc part2*(input: string): int64 =
  let reactions = input.parseReactions
  var (a, b) = (0.int64, trillion)
  while a < b:
    let mid = (a + b) div 2
    if reactions.numOre(mid) > trillion:
      b = mid - 1
    else:
      a = mid + 1
  if reactions.numOre(a) > trillion: a - 1 else: a
