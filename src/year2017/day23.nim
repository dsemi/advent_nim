import fusion/matching
import math
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
    Set, Sub, Mul, Jnz

  Instr = object
    kind: InstrKind
    a: Param
    b: Param

  Prog = ref object
    reg: array['a'..'h', int]
    line: int
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

proc parseInstrs(input: string): Prog =
  var instrs: seq[Instr]
  for line in input.splitLines:
    case line.splitWhitespace:
      of ["set", @r, @v]:
        instrs.add(Instr(kind: Set, a: r.parseReg, b: v.parseReg))
      of ["sub", @r, @v]:
        instrs.add(Instr(kind: Sub, a: r.parseReg, b: v.parseReg))
      of ["mul", @r, @v]:
        instrs.add(Instr(kind: Mul, a: r.parseReg, b: v.parseReg))
      of ["jnz", @a, @b]:
        instrs.add(Instr(kind: Jnz, a: a.parseReg, b: b.parseReg))
  Prog(instrs: instrs)

proc val(prog: Prog, p: Param): int =
  case p.kind:
    of Reg: prog.reg[p.r]
    of Val: p.v

proc isPrime(n: int): bool =
  result = true
  if n mod 2 == 0:
    return false
  for i in countup(3, n.float.sqrt.int, 2):
    if n mod i == 0:
      return false

proc run(p: var Prog; debug: bool = false): int =
  while p.line in p.instrs.low..p.instrs.high:
    if not debug and p.line + 14 <= p.instrs.len:
      case p.instrs[p.line..p.line+13]:
        of [(kind: Set, a: @e, b: (kind: Val, v: == 2)),
            (kind: Set, a: @g, b: @d),
            (kind: Mul, a: == g, b: == e),
            (kind: Sub, a: == g, b: @b),
            (kind: Jnz, a: == g, b: (kind: Val, v: == 2)),
            (kind: Set, a: @f, b: (kind: Val, v: == 0)),
            (kind: Sub, a: == e, b: (kind: Val, v: == -1)),
            (kind: Set, a: == g, b: == e),
            (kind: Sub, a: == g, b: == b),
            (kind: Jnz, a: == g, b: (kind: Val, v: == -8)),
            (kind: Sub, a: == d, b: (kind: Val, v: == -1)),
            (kind: Set, a: == g, b: == d),
            (kind: Sub, a: == g, b: == b),
            (kind: Jnz, a: == g, b: (kind: Val, v: == -13))]:
          let (toCheck, innerCounter, outerCounter, workspace, primeCheck) = (b, e, d, g, f)
          let v = p.reg[toCheck.r]
          p.reg[innerCounter.r] = v
          p.reg[outerCounter.r] = v
          p.reg[workspace.r] = 0
          p.reg[primeCheck.r] = int(v.isPrime)
          p.line += 14
          continue
    let instr = p.instrs[p.line]
    case instr.kind:
      of Set: p.reg[instr.a.r] = val(p, instr.b)
      of Sub: p.reg[instr.a.r] -= val(p, instr.b)
      of Mul:
        if debug:
          inc result
        p.reg[instr.a.r] *= val(p, instr.b)
      of Jnz:
        if val(p, instr.a) != 0:
          p.line += val(p, instr.b) - 1
    inc p.line

proc part1*(input: string): int =
  var prog = input.parseInstrs
  prog.run(debug = true)

proc part2*(input: string): int =
  var prog = input.parseInstrs
  prog.reg['a'] = 1
  discard prog.run
  prog.reg['h']
