import algorithm
import math
import sequtils
import strutils
import sugar
import tables

type
  Grid = seq[seq[bool]]
  Tile = object
    num: int
    grid: Grid

proc parse(input: string): seq[Tile] =
  for part in input.split("\n\n"):
    let lns = part.splitLines
    result.add(Tile(num: lns[0].split[^1][0..^2].parseInt,
                    grid: lns[1..^1].mapIt(it.mapIt(it == '#'))))

proc transpose(g: var Grid) =
  for i in g.low .. g.high:
    for j in i+1 .. g.high:
      swap(g[i][j], g[j][i])

iterator orientations(tile: Grid): Grid =
  var t = tile
  for _ in 0..3:
    yield t
    transpose(t)
    yield t
    t.reverse

proc findCorners(tiles: seq[Tile]): (seq[int], Table[seq[bool], seq[Tile]]) =
  for tile in tiles:
    for t in orientations(tile.grid):
      let hash = t.mapIt(it[0])
      result[1].mgetOrPut(hash, newSeq[Tile]()).add(Tile(num: tile.num, grid: t))
  var m = initCountTable[int]()
  for v in result[1].values:
    if v.len == 1:
      m.inc(v[0].num)
  for k, v in m:
    if v == 4:
      result[0].add(k)

proc part1*(input: string): int =
  findCorners(parse(input))[0].prod

proc placeTiles(tiles: seq[Tile]): (seq[Tile], int) =
  let size = tiles.len.float.sqrt.int
  var grid = newSeq[Tile]()
  let (corners, m) = findCorners(tiles)
  var start: Tile
  for tile in tiles:
    if tile.num in corners:
      start = tile
      break
  while m[start.grid.mapIt(it[^1])].len < 2 or m[start.grid[^1]].len < 2:
    transpose(start.grid)
    start.grid.reverse
  for r in 0 ..< size:
    for c in 0 ..< size:
      if r == 0 and c == 0:
        grid.add(start)
      elif c == 0:
        let prev = grid[(r-1)*size + c]
        for t in m[prev.grid[^1]]:
          if t.num != prev.num:
            grid.add(t)
            break
        grid[^1].grid.transpose
      else:
        let prev = grid[r*size + c - 1]
        for t in m[prev.grid.mapIt(it[^1])]:
          if t.num != prev.num:
            grid.add(t)
            break
  (grid, size)

proc match(a, b: seq[bool]): bool {.inline.} =
  for i, v in a:
    if v and v != b[i]:
      return false
  true

proc findSeaMonsters(p: seq[seq[bool]]): int =
  let monster = ["                  # ",
                 "#    ##    ##    ###",
                 " #  #  #  #  #  #   "]
  let cnt = monster.mapIt(it.count('#')).sum
  let pts = collect(newSeq):
    for row in monster:
      collect(newSeq):
        for v in row:
          v == '#'
  let (h, w) = (pts.len, pts[0].len)
  for row in countup(0, p.len - h):
    for j in countup(0, p[row].len - w):
      var all = true
      for i, line in pts:
        if not match(line, p[row+i][j ..< j+w]):
          all = false
          break
      if all:
        result += cnt

proc part2*(input: string): int =
  var (grid, size) = placeTiles(parse(input))
  var innerSize = 0
  for tile in grid.mitems:
    tile.grid = tile.grid[1..^2].mapIt(it[1..^2])
    innerSize = tile.grid.len
  var pic = newSeq[seq[bool]]()
  for i in countup(0, grid.high, size):
    for row in 0 ..< innerSize:
      var r = newSeq[bool]()
      for t in grid[i ..< i+size]:
        r.add(t.grid[row])
      pic.add(r)
  for row in pic:
    for v in row:
      result += v.int
  for p in orientations(pic):
    let ms = findSeaMonsters(p)
    if ms != 0:
      result -= ms
      break
