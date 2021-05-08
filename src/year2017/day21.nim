import algorithm
import sequtils
import strutils
import sugar
import tables
import unpack

import "../utils"

type Grid = seq[seq[bool]]

proc parseImg(input: string): Grid =
  input.split('/').map((row) => row.mapIt(it == '#'))

proc parseExpansions(input: string): Table[Grid, Grid] =
  for line in input.splitLines:
    [k, rest] <- line.split(" => ")
    let v = rest.parseImg
    var grid = k.parseImg
    for _ in 1..4:
      grid = grid.transpose
      result[grid] = v
      grid.reverse
      result[grid] = v

proc sqr(grid: Grid, i, j, span: int): Grid =
  var row = 0
  for x in i ..< i+span:
    result.add(grid[x][j..<j+span])

proc expandImage(img: Grid, m: Table[Grid, Grid]): Grid =
  let size = img.len
  let span = if size mod 2 == 0: 2 else: 3
  let sqSize = size div span
  let newSpan = span + 1
  let newSize = size * newSpan div span
  result = newSeqWith(newSize, newSeq[bool](newSize))
  for r in 0..<sqSize:
    for c in 0..<sqSize:
      let sq = img.sqr(r*span, c*span, span)
      let exp = m[sq]
      for x, row in exp:
        for y, v in row:
          result[r*newSpan+x][c*newSpan+y] = v

proc countPxAfterExpanding(input: string, n: int): int =
  let m = input.parseExpansions
  var img = parseImg(".#./..#/###")
  for _ in 1..n:
    img = img.expandImage(m)
  for row in img:
    for v in row:
      if v:
        inc result

proc part1*(input: string): int =
  input.countPxAfterExpanding(5)

proc part2*(input: string): int =
  input.countPxAfterExpanding(18)
