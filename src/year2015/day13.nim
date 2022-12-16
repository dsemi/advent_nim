import algorithm
import math
import sequtils
import strutils

import "../utils"

proc parse(input: string): seq[seq[int]] =
  let ui = uniqueIdx()
  let l = int(sqrt(float(input.splitlines.len))) + 1
  for _ in 1..l:
    result.add(newSeq[int](l))
  for line in input.splitlines:
    let parts = line.split
    let (p1, p2) = (parts[0], parts[10][0..^2])
    let n = (if parts[2] == "gain": 1 else: -1) * parts[3].parseInt
    result[ui(p1)][ui(p2)] += n
    result[ui(p2)][ui(p1)] += n

proc optimal(d: seq[seq[int]], p2: bool): int =
  var perm = toSeq(d.low..d.high)
  var run = true
  while run:
    var t = if p2: 0 else: d[perm[perm.low]][perm[perm.high]]
    for i in perm.low+1 .. perm.high:
      t += d[perm[i-1]][perm[i]]
    result = max(result, t)
    run = perm.nextPermutation

proc part1*(input: string): int =
  optimal(parse(input), false)

proc part2*(input: string): int =
  optimal(parse(input), true)
