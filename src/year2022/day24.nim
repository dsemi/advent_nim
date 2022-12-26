import bitops
import sequtils
import strutils

type Valley = ref object
  w, h: int
  nBlizz, sBlizz, wBlizz, eBlizz: seq[uint64]
  walls: seq[uint64]

proc parse(input: string): Valley =
  let grid = input.splitLines.mapIt(it.toSeq)
  let h = grid.len
  let w = grid[0].len
  var v = Valley(w: w, h: h)
  v.nBlizz = newSeq[uint64](w)
  v.sBlizz = newSeq[uint64](w)
  v.wBlizz = newSeq[uint64](w)
  v.eBlizz = newSeq[uint64](w)
  v.walls = newSeq[uint64](w)
  for r, row in grid:
    for c, val in row:
      case val
      of '^': v.nBlizz[c].setBit(r)
      of 'v': v.sBlizz[c].setBit(r)
      of '<': v.wBlizz[c].setBit(r)
      of '>': v.eBlizz[c].setBit(r)
      of '#': v.walls[c].setBit(r)
      else: discard
  v

proc shortestPath(v: var Valley, start, goal: (int, int)): int =
  var frontier = newSeq[uint64](v.w)
  frontier[start[1]].setBit(start[0])
  while not frontier[goal[1]].testBit(goal[0]):
    inc result
    var pwBlizz = v.wBlizz
    var peBlizz = v.eBlizz
    var pFrontier = frontier
    for c in 0 ..< v.w:
      v.nBlizz[c] = clearMasked((v.nBlizz[c] shr 1) or ((v.nBlizz[c] and 2) shl (v.h - 3)), v.walls[c])
      v.sBlizz[c] = clearMasked((v.sBlizz[c] shl 1) or ((v.sBlizz[c] shr (v.h - 3)) and 2), v.walls[c])
      v.wBlizz[c] = pwBlizz[(c - 2 + v.w) mod (v.w - 2) + 1]
      v.eBlizz[c] = peBlizz[(c - 4 + v.w) mod (v.w - 2) + 1]
      frontier[c].setMask(bitor(pFrontier[c] shr 1, pFrontier[c] shl 1,
                                pFrontier[(c + 1 + v.w) mod v.w], pFrontier[(c - 1 + v.w) mod v.w]))
      frontier[c].clearMask(bitor(v.walls[c], v.nBlizz[c], v.sBlizz[c], v.wBlizz[c], v.eBlizz[c]))


proc part1*(input: string): int =
  var valley = input.parse
  valley.shortestPath((0, 1), (valley.h-1, valley.w-2))

proc part2*(input: string): int =
  var valley = input.parse
  let (start, goal) = ((0, 1), (valley.h-1, valley.w-2))
  result += valley.shortestPath(start, goal)
  result += valley.shortestPath(goal, start)
  result += valley.shortestPath(start, goal)
