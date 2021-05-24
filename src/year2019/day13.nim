import fusion/matching
import deques

import "../utils"
import "intcode"

{.experimental: "caseStmtMacros".}

type
  Tile = enum
    Empty, Wall, Block, Paddle, Ball

  InstrKind = enum
    Draw, Score

  Instr = object
    case kind: InstrKind
    of Draw:
      pos: Coord
      tile: Tile
    of Score:
      v: int

iterator parseInstrs(prog: var Program): Instr =
  var i = 0
  var buf: array[3, int]
  while not prog.done:
    prog.run
    for v in prog.recv:
      buf[i] = v
      inc i
      if i == 3:
        i = 0
        case buf:
          of [== -1, == 0, @score]: yield Instr(kind: Score, v: score)
          of [@x, @y, @tile]: yield Instr(kind: Draw, pos: (x, y), tile: Tile(tile))

proc part1*(input: string): int =
  var prog = input.parse
  for instr in prog.parseInstrs:
    result += int(instr.kind == Draw and instr.tile == Block)

proc part2*(input: string): int =
  var prog = input.parse
  prog[0] = 2
  var ball, paddle: int
  for instr in prog.parseInstrs:
    if instr.kind == Draw and instr.tile == Ball:
      ball = instr.pos[0]
    elif instr.kind == Draw and instr.tile == Paddle:
      paddle = instr.pos[0]
    elif instr.kind == Score:
      result = instr.v
    if prog.output[].len == 0:
      prog.send([system.cmp(ball, paddle)])
