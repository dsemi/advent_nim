import deques
import fusion/matching
import options
import strutils
import sugar

import "../utils"

{.experimental: "caseStmtMacros".}

type
  Sim = ref object
    reg: array['a'..'z', int]
    line: int
    instrs: seq[Instr]
    sends: int

  Val = (Sim) -> int

  InstrKind = enum
    Snd, Set, Add, Mul, Mod, Rcv, Jgz

  Instr = object
    kind: InstrKind
    r: char
    v: Val
    a: Val
    b: Val

proc val(v: string): Val =
  (s: Sim) => (if v[0] in 'a'..'z': s.reg[v[0]] else: v.parseInt)

proc parseInstrs(input: string): seq[Instr] =
  for line in input.splitLines:
    result.add(
      case line.splitWhitespace:
        of ["snd",     @v]: Instr(kind: Snd, v: val(v))
        of ["set", @r, @v]: Instr(kind: Set, r: r[0], v: val(v))
        of ["add", @r, @v]: Instr(kind: Add, r: r[0], v: val(v))
        of ["mul", @r, @v]: Instr(kind: Mul, r: r[0], v: val(v))
        of ["mod", @r, @v]: Instr(kind: Mod, r: r[0], v: val(v))
        of ["rcv", @r    ]: Instr(kind: Rcv, r: r[0])
        of ["jgz", @a, @b]: Instr(kind: Jgz, a: val(a), b: val(b))
        else: raiseAssert "Parse error: " & line)

proc run(s: var Sim, send: (int) -> void, recv: () -> Option[int]) =
  while s.line in s.instrs.low..s.instrs.high:
    let instr = s.instrs[s.line]
    case instr.kind:
      of Snd:
        inc s.sends
        send(instr.v(s))
      of Set: s.reg[instr.r] = instr.v(s)
      of Add: s.reg[instr.r] += instr.v(s)
      of Mul: s.reg[instr.r] *= instr.v(s)
      of Mod: s.reg[instr.r] %= instr.v(s)
      of Rcv:
        let v = recv()
        if v.isNone: break
        s.reg[instr.r] = v.get
      of Jgz:
        let a = instr.a(s)
        let b = instr.b(s)
        if a > 0: s.line += b - 1
    s.line += 1

proc part1*(input: string): int =
  var s = Sim(instrs: input.parseInstrs)
  var v = 0
  s.run(proc(x: int) = v = x, () => (if v == 0: some(v) else: none(int)))
  v

proc part2*(input: string): int =
  var s0 = Sim(instrs: input.parseInstrs)
  var s1 = Sim(instrs: input.parseInstrs)
  s1.reg['p'] = 1
  var q0: Deque[int]
  var q1: Deque[int]
  while true:
    s0.run(proc(x: int) = q0.addLast(x),
           () => (if q1.len > 0: some(q1.popFirst) else: none(int)))
    s1.run(proc(x: int) = q1.addLast(x),
           () => (if q0.len > 0: some(q0.popFirst) else: none(int)))
    if q0.len == 0 and q1.len == 0:
      return s1.sends
