import sequtils
import strutils
import sugar
import tables

import "../utils"

type
  PT = enum Outer, Inner
  Portal = object
    t: PT
    pos: Coord

  ST = enum Wall, Floor, Port, Start, End
  Square = object
    case t: ST
    of Wall: discard
    of Floor: discard
    of Start: discard
    of End: discard
    of Port: p: Portal

  Maze = object
    grid: seq[seq[Square]]
    moves: Table[Coord, seq[(int, Coord)]]

proc parseMaze(input: string): (ref Maze, Coord, Coord) =
  let grid = input.splitLines.mapIt(it.toSeq)
  var portals = initTable[string, seq[Portal]]()
  for r in grid.low..grid.high:
    for c in grid[r].low..grid[r].high:
      if grid[r][c] in {'A'..'Z'}:
        if r > 0 and grid[r-1][c] in {'A'..'Z'} or c > 0 and grid[r][c-1] in {'A'..'Z'}:
          continue
        let (k, b, coord) = if r > 0 and grid[r-1][c] == '.':
                              ([grid[r][c], grid[r+1][c]], r + 2 == grid.len, (r - 1, c))
                            elif c > 0 and grid[r][c - 1] == '.':
                              ([grid[r][c], grid[r][c+1]], c + 2 == grid[r].len, (r, c - 1))
                            elif grid[r+1][c] in {'A'..'Z'}:
                              ([grid[r][c], grid[r+1][c]], r == 0, (r + 2, c))
                            else:
                              ([grid[r][c], grid[r][c+1]], c == 0, (r, c + 2))
        portals.mgetOrPut(k.join, @[]).add(Portal(t: if b: Outer else: Inner, pos: coord))
  var bi = initTable[Portal, Portal]()
  for k, ps in portals.pairs:
    if ps.len == 2:
      bi[ps[0]] = ps[1]
      bi[ps[1]] = ps[0]
    elif k == "AA":
      result[1] = ps[0].pos
    elif k == "ZZ":
      result[2] = ps[0].pos
  let grid2 = collect:
    for r, row in grid:
      collect:
        for c, v in row:
          if Portal(t: Outer, pos: (r, c)) in bi:
            Square(t: Port, p: bi[Portal(t: Outer, pos: (r, c))])
          elif Portal(t: Inner, pos: (r, c)) in bi:
            Square(t: Port, p: bi[Portal(t: Inner, pos: (r, c))])
          elif (r, c) == result[1]:
            Square(t: Start)
          elif (r, c) == result[2]:
            Square(t: End)
          elif v == '.':
            Square(t: Floor)
          else:
            Square(t: Wall)
  result[0] = new(Maze)
  result[0].grid = grid2

proc availableMoves(m: ref Maze, pos: Coord): seq[(int, Coord)] =
  if pos notin m.moves:
    var moves = newSeq[(int, Coord)]()
    let s = m.grid[pos.x][pos.y]
    if s.t == Port:
      moves.add (1, s.p.pos)
    proc neighbors(st: Coord): iterator: Coord =
      return iterator(): Coord =
        if st != pos and m.grid[st.x][st.y].t != Floor:
          return
        for d in [(1, 0), (-1, 0), (0, 1), (0, -1)]:
          let st2 = st + d
          if m.grid[st2.x][st2.y].t != Wall:
            yield st2
    for d, st in bfs(pos, neighbors):
      if m.grid[st.x][st.y].t != Floor:
        moves.add (d, st)
    m.moves[pos] = moves
  m.moves[pos]

proc part1*(input: string): int =
  let (maze, start, done) = input.parseMaze
  for d, st in dijkstra(start, proc(p: Coord): seq[(int, Coord)] = maze.availableMoves(p)):
    if st == done:
      return d

proc part2*(input: string): int =
  let (maze, start, done) = input.parseMaze
  proc neighbs(st: (Coord, int)): iterator: (int, (Coord, int)) =
    let (x, depth) = st
    return iterator(): (int, (Coord, int)) =
      for dist, pos in maze.availableMoves(x).items:
        let v = maze.grid[pos.x][pos.y]
        if v.t == Port and v.p.t == Outer and v.p.pos == x:
          if depth > 0:
            yield (dist, (pos, depth-1))
        elif v.t == Port and v.p.t == Inner and v.p.pos == x:
          yield (dist, (pos, depth+1))
        else:
          yield (dist, (pos, depth))
  for d, st in dijkstra((start, 0), neighbs):
    if st == (done, 0):
      return d
