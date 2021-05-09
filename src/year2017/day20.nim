import re
import sequtils
import strutils
import sugar
import tables

import "../utils"

type Particle = object
  pos: Coord3
  vel: Coord3
  acc: Coord3

let reg = re"-?\d+"

proc parseParticles(input: string): seq[Particle] =
  for line in input.splitLines:
    let cs = collect(newSeq):
      for comp in line.split(", "):
        let ds = comp.findAll(reg).map(parseInt)
        (ds[0], ds[1], ds[2])
    result.add(Particle(pos: cs[0], vel: cs[1], acc: cs[2]))

proc part1*(input: string): int =
  var m = int.high
  for i, p in input.parseParticles:
    let v = p.acc.abs.sum
    if v < m:
      m = v
      result = i

proc step(p: var Particle) =
  p.vel += p.acc
  p.pos += p.vel

proc removeCollisions(ps: seq[Particle]): seq[Particle] =
  let tbl = ps.mapIt(it.pos).toCountTable
  for p in ps:
    if tbl[p.pos] == 1:
      result.add(p)

proc part2*(input: string): int =
  var ps = input.parseParticles
  for _ in 1..100:
    for p in ps.mitems:
      p.step
    ps = ps.removeCollisions
  ps.len
