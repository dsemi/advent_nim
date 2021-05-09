import sequtils
import strscans
import strutils

import "../utils"

type Claim = object
  num: int
  rect: (Coord, Coord)

proc parseClaims(input: string): seq[Claim] =
  for line in input.splitLines:
    var n, x, y, w, h: int
    doAssert line.scanf("#$i @ $i,$i: $ix$i", n, x, y, w, h)
    result.add(Claim(num: n, rect: ((x, y), (x+w-1, y+h-1))))

proc coordFreq(claims: seq[Claim]): seq[seq[int]] =
  let maxX = claims.mapIt(it.rect[1][0]).max
  let maxY = claims.mapIt(it.rect[1][1]).max
  result = newSeqWith(maxX+1, newSeq[int](maxY+1))
  for claim in claims:
    for (x, y) in countup(claim.rect[0], claim.rect[1]):
      inc result[x][y]

proc part1*(input: string): int =
  for col in input.parseClaims.coordFreq:
    for v in col:
      if v > 1:
        inc result

proc part2*(input: string): int =
  let claims = input.parseClaims
  let grid = claims.coordFreq
  for claim in claims:
    block next:
      for (x, y) in countup(claim.rect[0], claim.rect[1]):
        if grid[x][y] != 1:
          break next
      return claim.num
