import fusion/matching
import sequtils
import strutils
import sugar
import tables

import "../utils"
import "intcode"

proc parseGrid(input: seq[int]): seq[seq[char]] =
  let input = input.mapIt(it.chr).join
  for line in input.splitLines:
    result.add(toSeq(line))

proc isScaffold(grid: seq[seq[char]], pos: Coord): bool =
  pos[1] in grid.low..grid.high and
  pos[0] in grid[pos[1]].low..grid[pos[1]].high and
  grid[pos[1]][pos[0]] in "#^<>v"

proc part1*(input: string): int =
  var prog = input.parse
  prog.run
  let ins = collect(newSeq):
    for v in prog.recv:
      v
  let grid = ins.parseGrid
  for y in grid.low..grid.high:
    for x in grid[y].low..grid[y].high:
      if [(x, y), (x+1, y), (x, y+1), (x-1, y), (x, y-1)].allIt(grid.isScaffold(it)):
        result += x * y

const dir = {
  '^': ( 0, -1),
  'v': ( 0,  1),
  '<': (-1,  0),
  '>': ( 1,  0),
}.toTable

proc findPath(grid: seq[seq[char]]): seq[string] =
  var sPos: Coord
  var sDir: char
  for r, row in grid:
    for c, v in row:
      if v in "^><v":
        sPos = (c, r)
        sDir = v
        break

  proc go(pos, dir: Coord): seq[string] =
    let (x, y) = dir
    proc keepMoving(c: string, d: Coord): seq[string] =
      var p = pos + d
      if not grid.isScaffold(p):
        return
      while grid.isScaffold(p + d):
        p += d
      result.add(c)
      result.add($(p - pos).abs.sum)
      result.add(go(p, d))
    result.add(keepMoving("L", (y, -x)))
    result.add(keepMoving("R", (-y, x)))
  let flatPath = go(sPos, dir[sDir])
  for i in countup(flatPath.low, flatPath.high, 2):
    result.add($flatPath[i] & "," & $flatPath[i+1])

proc split(x: seq[string], s: seq[string]): seq[seq[string]] =
  var i, c: int
  while i <= x.len - s.len:
    if x[i..<i+s.len] == s:
      result.add(x[c..<i])
      i += s.len
      c = i
      continue
    inc i
  result.add(x[c..x.high])

proc join(x: seq[seq[string]], j: seq[string]): seq[string] =
  result.add(x[0])
  for v in x[1..^1]:
    result.add(j)
    result.add(v)

proc compress(instrs: seq[string]): seq[seq[string]] =
  proc go(xs: seq[seq[string]], fns: int): Option[seq[seq[string]]] =
    if xs.len == 0:
      var tmp: seq[seq[string]]
      return some(tmp)
    if fns == 0:
      return none(seq[seq[string]])
    for i in 1..xs[0].len:
      let candidate = xs[0][0..<i]
      var fragments: seq[seq[string]]
      for x in xs:
        for y in x.split(candidate):
          if y.len > 0:
            fragments.add(y)
      if Some(@res) ?= go(fragments, fns-1):
        return some(@[candidate] & res)
  let replMap = @[@["A"], @["B"], @["C"]].zip(go(@[instrs], 3).get)
  @[replMap.foldl(a.split(b[1]).join(b[0]), instrs)] & replMap.mapIt(it[1])

proc part2*(input: string): int =
  var prog = input.parse
  prog.run
  let ins = collect(newSeq):
    for v in prog.recv:
      v
  let grid = ins.parseGrid
  let inps = (grid.findPath.compress.mapIt(it.join(",")) & @["n"]).join("\n") & "\n"
  prog = input.parse
  prog[0] = 2
  prog.send(inps.mapIt(it.ord))
  prog.run
  for v in prog.recv:
    result = v
