import algorithm
import fusion/matching
import math
import sequtils
import strutils
import tables

type Room = object
  name: string
  sectorId: int
  checksum: string

iterator parseRooms(input: string): Room =
  for line in input.splitLines:
    [@name, @rest] := line.rsplit('-', 1)
    [@sector, @rest2] := rest.split('[')
    yield Room(name: name, sectorId: sector.parseInt, checksum: rest2[0..^2])

proc isReal(room: Room): bool =
  let tbl = toCountTable(room.name.replace("-", ""))
  room.checksum == toSeq(tbl.pairs).sortedByIt((-it[1], it[0]))[0..4].mapIt($it[0]).join

proc part1*(input: string): int =
  for room in parseRooms(input):
    if room.isReal:
      result += room.sectorId

proc rotate(n: int, c: char): char =
  if c == ' ':
    return '-'
  return (floorMod(c.ord - n - 97, 26) + 97).chr

proc part2*(input: string): int =
  for room in parseRooms(input):
    if "northpole".mapIt(rotate(room.sectorId, it)).join in room.name:
      return room.sectorId
