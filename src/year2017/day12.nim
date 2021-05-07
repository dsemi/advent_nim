import deques
import sequtils
import sets
import strutils
import sugar
import tables
import unpack

import "../utils"

proc parsePipes(input: string): Table[int, seq[int]] =
  for line in input.splitLines:
    [a, b] <- line.split(" <-> ")
    result[a.parseInt] = b.split(", ").map(parseInt)

proc part1*(input: string): int =
  let m = input.parsePipes
  for (d, v) in bfs(0, (n) => m[n].seqToIter):
    inc result

proc part2*(input: string): int =
  let m = input.parsePipes
  var seen: HashSet[int]
  for n in m.keys:
    if n notin seen:
      inc result
      seen.incl(toSeq(bfs(n, (n) => m[n].seqToIter)).mapIt(it[1]).toHashSet)
