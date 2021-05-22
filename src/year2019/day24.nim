import sequtils
import intsets
import strutils

type Planet = seq[seq[bool]]

proc parseGrid(input: string): Planet =
  for row in input.splitLines:
    result.add(@[])
    for v in row:
      result[^1].add(v == '#')

proc neighborCounts(p: Planet): seq[seq[int]] =
  result = newSeqWith(p.len, newSeq[int](p[0].len))
  for r, row in p:
    for c, _ in row:
      for (dr, dc) in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
        let r2 = r + dr
        let c2 = c + dc
        if r2 in p.low..p.high and c2 in p[r2].low..p[r2].high:
          result[r][c] += p[r2][c2].int

proc nextBug(v: bool, adjBugs: int): bool =
  if v: adjBugs == 1
  else: adjBugs == 1 or adjBugs == 2

proc biodiversity(p: Planet): int =
  var i = 1
  for row in p:
    for v in row:
      result += i * v.int
      i *= 2

proc part1*(input: string): int =
  var planet = input.parseGrid
  var s: IntSet
  result = planet.biodiversity
  while result notin s:
    s.incl(result)
    let counts = planet.neighborCounts
    for r, row in planet.mpairs:
      for c, v in row.mpairs:
        v = v.nextBug(counts[r][c])
    result = planet.biodiversity

const empty = newSeqWith(5, newSeq[bool](5))

proc step(planets: var seq[Planet]) =
  planets = @[empty] & planets & @[empty]
  var counts = planets.map(neighborCounts)
  for i in counts.low+1..counts.high-1:
    for r, row in counts[i].mpairs:
      for c, v in row.mpairs:
        if r == 2 and c == 2:
          v = 0
        elif r == 1 and c == 2:
          for x in 0..4:
            v += planets[i+1][0][x].int
        elif r == 3 and c == 2:
          for x in 0..4:
            v += planets[i+1][4][x].int
        elif r == 2 and c == 1:
          for y in 0..4:
            v += planets[i+1][y][0].int
        elif r == 2 and c == 3:
          for y in 0..4:
            v += planets[i+1][y][4].int
        else:
          if r == 0:
            v += planets[i-1][1][2].int
          elif r == 4:
            v += planets[i-1][3][2].int
          if c == 0:
            v += planets[i-1][2][1].int
          elif c == 4:
            v += planets[i-1][2][3].int

  for i, planet in planets.mpairs:
    for r, row in planet.mpairs:
      for c, v in row.mpairs:
        v = v.nextBug(counts[i][r][c])

proc part2*(input: string): int =
  var planets = @[empty, input.parseGrid, empty]
  for _ in 1..200:
    planets.step
  for p in planets:
    for row in p:
      for v in row:
        result += v.int
