import deques
import nre except toSeq
import sequtils
import strutils
import tables

import "../utils"

proc makePortal(m: RegexMatch): (int, string) =
  if m.match[0] == '.': (m.matchBounds.a, m.match[1..^1])
  else: (m.matchBounds.b, m.match[0..^2])

proc parseMaze(input: string): (seq[seq[bool]], Coord, Coord, Table[Coord, (Coord, int)]) =
  let rows = input.splitLines
  var grid = newSeqWith(rows.len, newSeq[bool](rows[0].len))
  for r, row in rows:
    for c, v in row:
      grid[r][c] = v == '.'

  let outreg = re"^[A-Z]{2}\.|\.[A-Z]{2}$"
  let innreg = re"(?<!^)[A-Z]{2}\.|\.[A-Z]{2}(?!$)"

  var outer: Table[string, Coord]
  var inner: Table[string, Coord]

  for r, row in rows:
    for m in row.findIter(outreg):
      let (c, s) = m.makePortal
      outer[s] = (r, c)
    for m in row.findIter(innreg):
      let (c, s) = m.makePortal
      inner[s] = (r, c)
  for c, col in rows.mapIt(toSeq(it)).transpose.mapIt(it.join):
    for m in col.findIter(outreg):
      let (r, s) = m.makePortal
      outer[s] = (r, c)
    for m in col.findIter(innreg):
      let (r, s) = m.makePortal
      inner[s] = (r, c)

  var portals: Table[Coord, (Coord, int)]
  for (k, v1) in outer.pairs:
    if k in inner:
      let v2 = inner[k]
      portals[v1] = (v2, -1)
      portals[v2] = (v1, 1)
  (grid, outer["AA"], outer["ZZ"], portals)

proc part1*(input: string): int =
  let (grid, start, finish, portals) = input.parseMaze
  proc neighbors(st: Coord): iterator: Coord =
    return iterator(): Coord =
      if st in portals:
        yield portals[st][0]
      for d in [(1, 0), (-1, 0), (0, 1), (0, -1)]:
        let st2 = st + d
        if grid[st2[0]][st2[1]]:
          yield st2
  for (d, st) in bfs(start, neighbors):
    if st == finish:
      return d

proc part2*(input: string): int =
  let (grid, start, finish, portals) = input.parseMaze
  proc neighbors(st: (Coord, int)): iterator: (Coord, int) =
    return iterator(): (Coord, int) =
      if st[0] in portals:
        let (st2, d) = portals[st[0]]
        if d + st[1] >= 0:
          yield (st2, d + st[1])
      for d in [(1, 0), (-1, 0), (0, 1), (0, -1)]:
        let st2 = (st[0] + d, st[1])
        if grid[st2[0][0]][st2[0][1]]:
          yield st2
  for (d, st) in bfs((start, 0), neighbors):
    if st == (finish, 0):
      return d
