import sequtils
import strutils
import sugar

proc parse(input: string): seq[seq[int8]] =
  input.splitLines.map((line) => line.mapIt(int8(it.ord - '0'.ord)))

proc dijkstra(grid: openArray[seq[int8]]): int =
  let dim = grid.len + 2
  var lookup = newSeq[int](dim * dim)
  for r, row in grid:
    for c, v in row:
      lookup[dim * (r+1) + c + 1] = v
  let goal = dim * dim - dim - 2
  var q = newSeqWith(16, newSeq[int]())
  var tmp = newSeq[int]()
  q[0].add(dim * 1 + 1)
  for qi in 0..int.high:
    tmp.setLen(0)
    swap(q[qi mod 16], tmp)
    for p in tmp:
      if lookup[p] < 1:
        continue
      if p == goal:
        return qi
      lookup[p] *= -1
      for n in [p-1, p+1, p-dim, p+dim]:
        if lookup[n] >= 1:
          q[(qi + lookup[n]) mod 16].add(n)

proc part1*(input: string): int =
  dijkstra(parse(input))

proc part2*(input: string): int =
  var grid = parse(input)
  let (rows, cols) = (grid.len, grid[0].len)
  for row in grid.mitems:
    for i in 1 .. 4:
      row.add(row[0..<cols].mapIt(int8((it + i - 1) mod 9 + 1)))
  for i in 1 .. 4:
    for row in grid[0..<rows]:
      grid.add(row.mapIt(int8((it + i - 1) mod 9 + 1)))
  dijkstra(grid)
