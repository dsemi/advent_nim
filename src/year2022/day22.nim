import re
import sequtils
import strutils
import tables

import "../utils"

proc walk(input: string, portals: Table[(Coord, Coord), (Coord, Coord)]): int =
  let pts = input.split("\n\n")
  let grid = pts[0].splitLines.mapIt(it.toSeq)
  var pos: Coord = (0, grid[0].find('.'))
  var dir: Coord = (0, 1)
  for instr in pts[1].findAll(re"\d+|."):
    if instr == "L":
      dir *= (0, 1)
    elif instr == "R":
      dir *= (0, -1)
    else:
      for _ in 1..instr.parseInt:
        let (pos2, dir2) = if (pos, dir) in portals: portals[(pos, dir)]
                           else: (pos + dir, dir)
        if grid[pos2] == '#':
          break
        pos = pos2
        dir = dir2
  let row = pos.x + 1
  let col = pos.y + 1
  let facing = if dir == (0, 1): 0
               elif dir == (1, 0): 1
               elif dir == (0, -1): 2
               elif dir == (-1, 0): 3
               else: raiseAssert "Invalid direction"
  1000*row + 4*col + facing

proc part1*(input: string): int =
  var portals = initTable[(Coord, Coord), (Coord, Coord)]()
  for i in 0..49:
    portals[((0, 50+i), (-1, 0))] = ((149, 50+i), (-1, 0))
    portals[((149, 50+i), (1, 0))] = ((0, 50+i), (1, 0))
    portals[((0, 100+i), (-1, 0))] = ((49, 100+i), (-1, 0))
    portals[((49, 100+i), (1, 0))] = ((0, 100+i), (1, 0))
    portals[((0+i, 50), (0, -1))] = ((0+i, 149), (0, -1))
    portals[((0+i, 149), (0, 1))] = ((0+i, 50), (0, 1))
    portals[((50+i, 50), (0, -1))] = ((50+i, 99), (0, -1))
    portals[((50+i, 99), (0, 1))] = ((50+i, 50), (0, 1))
    portals[((100, 0+i), (-1, 0))] = ((199, 0+i), (-1, 0))
    portals[((199, 0+i), (1, 0))] = ((100, 0+i), (1, 0))
    portals[((100+i, 0), (0, -1))] = ((100+i, 99), (0, -1))
    portals[((100+i, 99), (0, 1))] = ((100+i, 0), (0, 1))
    portals[((150+i, 0), (0, -1))] = ((150+i, 49), (0, -1))
    portals[((150+i, 49), (0, 1))] = ((150+i, 0), (0, 1))
  input.walk(portals)

proc part2*(input: string): int =
  var portals = initTable[(Coord, Coord), (Coord, Coord)]()
  for i in 0..49:
    portals[((0, 50+i), (-1, 0))] = ((150+i, 0), (0, 1))
    portals[((150+i, 0), (0, -1))] = ((0, 50+i), (1, 0))
    portals[((0, 100+i), (-1, 0))] = ((199, 0+i), (-1, 0))
    portals[((199, 0+i), (1, 0))] = ((0, 100+i), (1, 0))
    portals[((0+i, 50), (0, -1))] = ((149-i, 0), (0, 1))
    portals[((149-i, 0), (0, -1))] = ((0+i, 50), (0, 1))
    portals[((0+i, 149), (0, 1))] = ((149-i, 99), (0, -1))
    portals[((149-i, 99), (0, 1))] = ((0+i, 149), (0, -1))
    portals[((49, 100+i), (1, 0))] = ((50+i, 99), (0, -1))
    portals[((50+i, 99), (0, 1))] = ((49, 100+i), (-1, 0))
    portals[((50+i, 50), (0, -1))] = ((100, 0+i), (1, 0))
    portals[((100, 0+i), (-1, 0))] = ((50+i, 50), (0, 1))
    portals[((149, 50+i), (1, 0))] = ((150+i, 49), (0, -1))
    portals[((150+i, 49), (0, 1))] = ((149, 50+i), (-1, 0))
  input.walk(portals)
