import math
import sequtils
import strscans
import strutils

import "../utils"

type Moon = object
  pos: seq[int]
  vel: seq[int]

proc parseMoons(input: string): seq[Moon] =
  for line in input.splitLines:
    var x, y, z: int
    doAssert line.scanf("<x=$i, y=$i, z=$i>", x, y, z)
    result.add(Moon(pos: @[x, y, z], vel: @[0, 0, 0]))

proc step(moons: var seq[Moon]) =
  for i in moons.low..moons.high:
    for j in moons.low..moons.high:
      for x in moons[i].vel.low..moons[i].vel.high:
        moons[i].vel[x] += cmp(moons[j].pos[x], moons[i].pos[x])
  for moon in moons.mitems:
    for x in moon.pos.low..moon.pos.high:
      moon.pos[x] += moon.vel[x]

proc part1*(input: string): int =
  var m = input.parseMoons
  for _ in 1..1000:
    m.step
  m.mapIt(it.pos.mapIt(it.abs).sum * it.vel.mapIt(it.abs).sum).sum

proc findCycle(moons: seq[Moon]): int =
  var ms = moons
  for i in 1..int.high:
    ms.step
    if ms == moons:
      return i

proc part2*(input: string): int =
  let moons = input.parseMoons
  result = 1
  for n in 0..2:
    result = result.lcm(moons.mapIt(Moon(pos: it.pos[n..n], vel: it.vel[n..n])).findCycle)
