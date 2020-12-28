import math
import sequtils
import sets
import strutils
import sugar
import tables
import unpack

type Tile = (int, seq[seq[bool]])

proc parse(input: string): seq[Tile] =
  for part in input.split("\n\n"):
    [t, *grid] <- part.splitlines
    result.add((t.split()[^1][0 .. ^2].parseInt, grid.map((row) => row.mapIt(it == '#'))))

proc hashSide(arr: seq[bool]): int =
  let narr = arr.mapIt(int(it))
  min(narr.foldl(2 * a + b), narr.foldr(a + 2 * b))

proc findCorners(tiles: seq[Tile]): seq[int] =
  var m = initTable[int, seq[int]]()
  for (n, tile) in tiles:
    m.mgetOrPut(hashSide(tile[0]), newSeq[int]()).add(n)
    m.mgetOrPut(hashSide(tile[^1]), newSeq[int]()).add(n)
    m.mgetOrPut(hashSide(tile.mapIt(it[0])), newSeq[int]()).add(n)
    m.mgetOrPut(hashSide(tile.mapIt(it[^1])), newSeq[int]()).add(n)
  var m2 = initCountTable[int]()
  for k, v in m:
    if v.len == 1:
      m2.inc(v[0])
  for k, v in m2:
    doAssert v <= 2
    if v == 2:
      result.add(k)

proc part1*(input: string): int =
  findCorners(parse(input)).prod

let transforms = [
  proc (m, x, y: int): (int, int) = (  x,   y),
  proc (m, x, y: int): (int, int) = (m-x,   y),
  proc (m, x, y: int): (int, int) = (  x, m-y),
  proc (m, x, y: int): (int, int) = (m-x, m-y),
  proc (m, x, y: int): (int, int) = (  y,   x),
  proc (m, x, y: int): (int, int) = (m-y,   x),
  proc (m, x, y: int): (int, int) = (  y, m-x),
  proc (m, x, y: int): (int, int) = (m-y, m-x),
]

iterator orientations[A](tile: seq[seq[A]]): seq[seq[A]] =
  for transform in transforms:
    var tile2 = tile
    for x in tile.low .. tile.high:
      for y in tile[0].low .. tile[0].high:
        let (x2, y2) = transform(tile.high, x, y)
        tile2[x2][y2] = tile[x][y]
    yield tile2

proc placeTiles(tiles: seq[Tile]): (Table[(int, int), Tile], int) =
  let corners = findCorners(tiles)
  var t1, t2 = newSeq[Tile]()
  for (n, t) in tiles:
    if n in corners:
      t1.add((n, t))
    else:
      t2.add((n, t))
  let size = int(sqrt(float(tiles.len)))
  proc go(c: int, m: var Table[(int, int), Tile], ta: seq[Tile], tb: seq[Tile]): bool =
    let isCorner = c in [0, size-1, size*(size-1), size*size-1]
    if ta.len == 0 and tb.len == 0:
      return true
    for (n, tile) in (if isCorner: ta else: tb):
      for t in orientations(tile):
        let row = c div size
        let col = c mod size
        if col > 0 and m[(row, col-1)][1].mapIt(it[^1]).zip(t.mapIt(it[0])).anyIt(it[0] != it[1]):
          continue
        if row > 0 and m[(row-1, col)][1][^1].zip(t[0]).anyIt(it[0] != it[1]):
          continue
        m[(row, col)] = (n, t)
        if go(c+1, m,
              if not isCorner: ta else: ta.filterIt(it[0] != n),
              if isCorner: tb else: tb.filterIt(it[0] != n)):
          return true
  var m = initTable[(int, int), Tile]()
  discard go(0, m, t1, t2)
  (m, size)

proc findSeaMonsters(p: seq[seq[bool]]): int =
  let monster = ["                  # ",
                 "#    ##    ##    ###",
                 " #  #  #  #  #  #   "]
  let pts = collect(newSeq):
    for r, row in monster:
      for c, v in row:
        if v == '#':
          (r, c)
  for arr in orientations(p):
    let s = collect(initHashSet):
      for r in 0 .. arr.len - 3:
        for c in 0 .. arr[0].len - 20:
          if pts.allIt(arr[it[0]+r][it[1]+c]):
            for pos in pts.mapIt((it[0]+r, it[1]+c)):
              {pos}
    if s.len > 0:
      return s.len

proc part2*(input: string): int =
  let (m, sz) = placeTiles(parse(input))
  let isz = m[(0, 0)][1].len - 2
  let p = collect(newSeq):
    for r in 0 ..< sz*isz:
      collect(newSeq):
        for c in 0 ..< sz*isz:
          m[(r div isz, c div isz)][1][r mod isz + 1][c mod isz + 1]
  let n = findSeaMonsters(p)
  p.mapIt(it.count(true)).sum - n
