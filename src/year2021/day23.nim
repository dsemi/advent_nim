import heapqueue
import math
import strutils

import "../utils"

const ROOM_XOR: uint32 = 0xffaa5500u32
const COST = [1u16, 10, 100, 1000]

const SAFE_SKIPS = [
    0u32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0x3, 0x7, 0x7, 0x7, 0x7, 0, 0, 0, 0x3, 0x707, 0xf0f, 0xf0f,
    0xf0f, 0, 0, 0, 0x3, 0x707, 0xf0f0f, 0x1f1f1f, 0x1f1f1f, 0,
]

proc readInput(input: string): uint32 =
  var b = input
  proc toGlyph(c: char): uint32 =
    uint32(byte(c) - 'A'.ord)
  var room = 0u32
  for i in 0..3:
    room = room or toGlyph(b[31]) shl (8 * i)
    room = room or toGlyph(b[45]) shl ((8 * i) + 2)
    b = b[2..^1]
  room xor (ROOM_XOR and 0x0f0f0f0f)

proc insertPart2(room: uint32): uint32 =
  let room = (room and 0x03030303u32) or ((room shl 4) and 0xc0c0c0c0u32)
  room xor 0x1c2c0c3c

proc baseCost(room: uint32): (int32, int32) =
  var room = room xor ROOM_XOR
  proc moveCost(dist: int32): int32 =
    2 * max(1, dist.abs)
  var base = 0i32
  var secondRow = 0i32
  for i in 0..3:
    let glyph0 = int32(room and 3)
    let glyph1 = int32((room shr 2) and 3)
    let cost0 = int32(COST[glyph0])
    let cost1 = int32(COST[glyph1])
    base += cost0 * (moveCost(int32(i) - glyph0) + 1)
    base += cost1 * moveCost(int32(i) - glyph1)
    secondRow += cost1
    room = room shr 8
  let cost1 = base + secondRow * 2 + 3333
  let cost2 = base + secondRow * 4 + 29115
  (cost1, cost2)

type Room = object
  room: uint32

proc empty(room: Room, r: int32): bool =
  ((room.room shr (8 * r)) and 0xff) == 0

proc get(room: Room, r: int32): int32 =
  r xor int32((room.room shr (8 * r)) and 3)

proc pop(room: var Room, r: int32) =
  let mask1 = 0xffu32 shl (8 * r)
  let mask2 = 0x3fu32 shl (8 * r)
  room.room = ((room.room shr 2) and mask2) or (room.room and not mask1)

type Hall = object
  hall: uint32

proc empty(hall: Hall, h: int32): bool =
  (hall.hall and (4u32 shl (4 * h))) == 0

proc clear(hall: var Hall, h: int32) =
  hall.hall = hall.hall and not (0xfu32 shl (4 * h))

proc set(hall: var Hall, h: int32, g: int32) =
  hall.hall = hall.hall or (4 or uint32(g)) shl (4 * h)

proc get(hall: Hall, h: int32): int32 =
  int32((hall.hall shr (4 * h)) and 3)

proc mask(hall: Hall): uint32 =
  hall.hall and 0x4444444

type State = object
  room: Room
  hall: Hall

proc newState(hash: uint64): State =
  State(room: Room(room: uint32(hash)), hall: Hall(hall: uint32(hash shr 32)))

proc hash(state: State): uint64 =
  (uint64(state.hall.hall) shl 32) or uint64(state.room.room)

proc solved(state: State): bool =
  (state.room.room or state.hall.hall) == 0

proc roomL(r: int32): int32 =
  r + 1

proc roomR(r: int32): int32 =
  r + 2

proc obstructed(state: State, r: int32, h: int32): bool =
  let (lo, hi) = if h <= roomL(r):
                   (h + 1, roomL(r))
                 else:
                   (roomR(r), h - 1)
  let mask = (16u32 shl (4 * hi)) - (1u32 shl (4 * lo))
  (state.hall.hall and mask) != 0

proc forceOne(state: var State): bool =
  for b in bits(state.hall.mask):
    let h = int32(b div 4)
    let r = state.hall.get(h)
    if state.room.empty(r) and not state.obstructed(r, h):
      state.hall.clear(h)
      return true
  for r in 0i32..3:
    if state.room.empty(r):
      continue
    let g = state.room.get(r)
    if g == r or not state.room.empty(g):
      continue
    if not state.obstructed(r, if r < g: roomR(g) else: roomL(g)):
      state.room.pop(r)
      return true

proc deadlocked(state: State): bool =
  let h43 = state.hall.hall and 0x0077000
  if h43 == 0x0047000 or h43 == 0x0057000:
    return true
  let h42 = state.hall.hall and 0x0070700
  if h42 == 0x0040700:
    return true
  let h32 = state.hall.hall and 0x0007700
  if h32 == 0x0004600 or h32 == 0x0004700:
    return true

proc crowded(state: State): bool =
  var h0 = 0
  var h = (state.hall.hall shr 2) or 0x10000000
  var satisfied = false
  for i in 0..7:
    if (h and 1) != 0:
      if h0 < i:
        let r0 = max(0, h0 - 2)
        let r1 = max(3, i - 2)
        let space = i - h0
        let mask = 3u32 shl (2 * space)
        for r in r0..r1:
          let rr = (state.room.room shr (8 * r)) and 0xff
          if (rr and mask) == 0:
            satisfied = true
      h0 = i + 1
    h = h shr 4
  not satisfied

proc neighbors(state: State, skip: uint32): seq[(int32, State, uint32)] =
  var skipRooms = 0
  for i in 0i32..2:
    let h = i + 2
    if not state.hall.empty(h):
      let mask = 0b1110 shl i
      skipRooms = skipRooms or (if i < state.hall.get(h): not mask else: mask)
  for r in 0i32..3:
    if (skipRooms and (1 shl r)) != 0 or state.room.empty(r):
      continue
    let g = state.room.get(r)
    let (lo, hi) = if r < g:
                     (roomR(r), roomL(g))
                   elif r > g:
                     (roomR(g), roomL(r))
                   else:
                     (roomL(r), roomR(r))
    for h in 0i32..6:
      if r != g and h >= lo and h <= hi:
        continue
      let skipIdx = 8 * r + h
      if (skip shr skipIdx and 1) != 0:
        continue
      if not state.hall.empty(h) or state.obstructed(r, h):
        continue
      var cost = if h < lo:
                   lo - h
                 elif hi < h:
                   h - hi
                 else:
                   0
      cost *= 2
      cost -= int32((int32(cost == 0) or int32(r == g)) == 0) + (int32(h == 0) or int32(h == 6))
      cost *= 2
      var n = state
      n.room.pop(r)
      n.hall.set(h, g)
      if n.deadlocked:
        continue
      var skips = SAFE_SKIPS[skipIdx]
      while n.forceOne:
        skips = 0
      if n.crowded:
        continue
      result.add((cost * int32(COST[g]), n, skips))

type Hash[SIZE : static[int], T] = object
  table: array[SIZE, (uint64, T)]

proc find[S, T](hash: Hash[S, T], key: uint64): int32 =
  var idx = int32(int(key) mod hash.table.len)
  while hash.table[idx][0] != 0 and hash.table[idx][0] != not key:
    idx += 1
    idx = idx and -int32(idx < hash.table.len)
  idx

proc insert[S, T](hash: var Hash[S, T], key: uint64, value: T) =
  let idx = hash.find(key)
  hash.table[idx] = (not key, value)

proc get[S, T](hash: var Hash[S, T], idx: int32): ptr T =
  addr hash.table[idx][1]

proc exists[S, T](hash: Hash[S, T], idx: int32): bool =
  hash.table[idx][0] != 0

proc solve(start: State): int32 =
  const TBL_SIZE: int = 14983
  var cost = Hash[TBL_SIZE, (uint16, uint32)]()
  for v in cost.table.mitems:
    v = (0u64, (0u16, 0u32))
  cost.insert(start.hash, (0u16, 0u32))
  var q = [(0i32, start.hash)].toHeapQueue
  while q.len > 0:
    let (queueCost, curHash) = q.pop
    let (curCost, curSkips) = cost.get(cost.find(curHash))[]
    if queueCost != int32(curCost):
      continue
    let cur = newState(curHash)
    if cur.solved:
      break
    for (delta, state, skips) in cur.neighbors(curSkips):
      let hash = state.hash
      let newCost = int32(curCost) + delta
      let newIdx = cost.find(hash)
      if not cost.exists(newIdx):
        cost.insert(hash, (uint16(newCost), skips))
        q.push((newCost, hash))
      else:
        let p = cost.get(newIdx)
        let (prevCost, prevSkips) = p[]
        if newCost == int32(prevCost):
          p[][1] = prevSkips and skips
        elif newCost < int32(prevCost):
          p[][0] = uint16(newCost)
          p[][1] = skips
          q.push((newCost, hash))
  int32(cost.get(cost.find(0u64))[][0])

proc part1*(input: string): int =
  let room = readInput(input)
  let base = baseCost(room)[0]
  base + solve(newState(uint64(room)))

proc part2*(input: string): int =
  let room = readInput(input)
  let base = baseCost(room)[1]
  base + solve(newState(uint64(insertPart2(room))))
