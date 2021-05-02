import algorithm
import deques
import fusion/matching
import hashes
import math
import re
import sets
import sequtils
import strutils
import tables

import "../utils"

{.experimental: "caseStmtMacros".}

type
  Pair = tuple
    chip: int
    gen: int

  Floors = object
    elev: int
    flrs: seq[Pair]

proc hash(floors: Floors): Hash =
  (floors.elev, floors.flrs).hash

let reg = re"\S+ (microchip|generator)"

proc parseFloors(input: string): Floors =
  var tbl: Table[string, Pair]
  for i, line in toSeq(input.splitLines):
    for item in findAll(line, reg):
      case item.splitWhitespace:
        of [@radiation, "generator"]:
          tbl.mgetOrPut(radiation, (0, 0)).gen = i+1
        of [@compat, "microchip"]:
          tbl.mgetOrPut(compat.split('-')[0], (0, 0)).chip = i+1
  Floors(elev: 1, flrs: toSeq(tbl.values).sorted)

proc isValid(fls: seq[Pair]): bool =
  for p in fls:
    if p.chip != p.gen and p.chip in fls.mapIt(it.gen):
      return false
  return true

proc isDone(floors: Floors): bool =
  floors.flrs.allIt(it.chip == 4 and it.gen == 4)

iterator allMoves(elev: int, elev2: int, fls: seq[Pair]): seq[Pair] =
  for i in fls.low..fls.high:
    if fls[i].chip == elev:
      var fls2 = fls
      fls2[i].chip = elev2
      yield fls2
    if fls[i].gen == elev:
      var fls2 = fls
      fls2[i].gen = elev2
      yield fls2

proc neighbors(floors: Floors): iterator: Floors =
  return iterator(): Floors =
    var neighbs: HashSet[Floors]
    let
      elev = floors.elev
      flrs = floors.flrs
    for e in [elev+1, elev-1]:
      if e > 0 and e <= 4:
        for flrs2 in allMoves(elev, e, flrs):
          if flrs2.isValid:
            let neighb = Floors(elev: e, flrs: flrs2.sorted)
            if neighb notin neighbs:
              neighbs.incl(neighb)
              yield neighb
          for flrs3 in allMoves(elev, e, flrs2):
            if flrs3.isValid:
              let neighb = Floors(elev: e, flrs: flrs3.sorted)
              if neighb notin neighbs:
                neighbs.incl(neighb)
                yield neighb

proc part1*(input: string): int =
  for (d, st) in bfs(input.parseFloors, neighbors):
    if st.isDone:
      return d

proc part2*(input: string): int =
  var floors = input.parseFloors
  floors.flrs = @[(1, 1), (1, 1)] & floors.flrs
  for (d, st) in bfs(floors, neighbors):
    if st.isDone:
      return d
