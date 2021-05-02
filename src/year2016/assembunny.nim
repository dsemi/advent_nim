import fusion/matching
import strutils

{.experimental: "caseStmtMacros".}

type
  ParamKind = enum
    Reg, Val

  Param = object
    case kind: ParamKind
    of Reg: r: char
    of Val: v: int

  InstrKind = enum
    Cpy, Inc, Dec, Jnz, Tgl, Out, Add, Mul, Nop

  Instr = object
    kind: InstrKind
    a: Param
    b: Param
    c: Param
    d: Param

  Prog* = ref object
    reg*: array['a'..'d', int]
    ip: int
    instrs: seq[Instr]

proc `==`(p1: Param, p2: Param): bool =
  if p1.kind == Reg:
    p1.kind == p2.kind and p1.r == p2.r
  else:
    p1.kind == p2.kind and p1.v == p2.v

proc parseReg(x: string): Param =
  try:
    return Param(kind: Val, v: x.parseInt)
  except ValueError:
    return Param(kind: Reg, r: x[0])

proc optimize(instrs: var seq[Instr]) =
  for i in instrs.low..instrs.high:
    if i + 6 <= instrs.len:
      case instrs[i..i+5]:
        of [(kind: Cpy, a: @a, b: @d),
            (kind: Inc, a: @c),
            (kind: Dec, a: @d2),
            (kind: Jnz, a: @d3, b: (kind: Val, v: == -2)),
            (kind: Dec, a: @b),
            (kind: Jnz, a: @b2, b: (kind: Val, v: == -5))]:
          if d == d2 and d == d3 and b == b2:
            instrs[i] = Instr(kind: Mul, a: a, b: b, c: c, d: d)
            instrs[i+1] = Instr(kind: Nop)
            instrs[i+2] = Instr(kind: Nop)
            instrs[i+3] = Instr(kind: Nop)
            instrs[i+4] = Instr(kind: Nop)
            instrs[i+5] = Instr(kind: Nop)
            continue
    if i + 3 <= instrs.len:
      case instrs[i..i+2]:
        of [(kind: Inc, a: @a),
            (kind: Dec, a: @b),
            (kind: Jnz, a: @b2, b: (kind: Val, v: == -2))]:
          if b == b2:
            instrs[i] = Instr(kind: Add, a: a, b: b)
            instrs[i+1] = Instr(kind: Nop)
            instrs[i+2] = Instr(kind: Nop)
            continue

proc parseInstrs*(input: string): Prog =
  var instrs: seq[Instr]
  for line in input.splitLines:
    case line.splitWhitespace:
      of ["cpy", @x, @y]:
        instrs.add(Instr(kind: Cpy, a: x.parseReg, b: y.parseReg))
      of ["inc", @x]:
        instrs.add(Instr(kind: Inc, a: x.parseReg))
      of ["dec", @x]:
        instrs.add(Instr(kind: Dec, a: x.parseReg))
      of ["jnz", @x, @y]:
        instrs.add(Instr(kind: Jnz, a: x.parseReg, b: y.parseReg))
      of ["tgl", @x]:
        instrs.add(Instr(kind: Tgl, a: x.parseReg))
      of ["out", @x]:
        instrs.add(Instr(kind: Out, a: x.parseReg))
  optimize(instrs)
  Prog(instrs: instrs)

# Could make a macro similar to `capture` that would provide vals
proc val(prog: Prog, p: Param): int =
  case p.kind:
    of Reg: prog.reg[p.r]
    of Val: p.v

proc toggle(instr: var Instr) =
  case instr.kind:
    of Cpy: instr.kind = Jnz
    of Inc: instr.kind = Dec
    of Dec: instr.kind = Inc
    of Jnz: instr.kind = Cpy
    of Tgl: instr.kind = Inc
    else:
      raiseAssert "Toggling invalid instruction"

iterator runWithOutput*(prog: var Prog): int =
  while prog.ip >= 0 and prog.ip < prog.instrs.len:
    let instr = prog.instrs[prog.ip]
    case instr.kind:
      of Cpy:
        prog.reg[instr.b.r] = val(prog, instr.a)
      of Inc:
        inc prog.reg[instr.a.r]
      of Dec:
        dec prog.reg[instr.a.r]
      of Jnz:
        if val(prog, instr.a) != 0:
          prog.ip += val(prog, instr.b) - 1
      of Tgl:
        let i = prog.ip + val(prog, instr.a)
        if i >= 0 and i < prog.instrs.len:
          prog.instrs[i].toggle
      of Out:
        yield val(prog, instr.a)
      of Add:
        prog.reg[instr.a.r] += prog.reg[instr.b.r]
        prog.reg[instr.b.r] = 0
      of Mul:
        prog.reg[instr.c.r] += val(prog, instr.a) * prog.reg[instr.b.r]
        prog.reg[instr.b.r] = 0
        prog.reg[instr.d.r] = 0
      of Nop:
        discard
    inc prog.ip

proc run*(prog: var Prog) =
  for _ in runWithOutput(prog):
    discard
