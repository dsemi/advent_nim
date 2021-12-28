import fusion/matching
import options
import sequtils
import sets
import strformat
import strutils

{.experimental: "caseStmtMacros".}

type
  VKind = enum
    Reg, Lit

  Value = object
    case kind: VKind
    of Reg: r: int
    of Lit: v: int

  IKind = enum
    Inp, Add, Mul, Div, Mod, Eql

  Instr = object
    kind: IKind
    a: int
    b: Value

  Prog = object
    regs: array[4, int]
    pc: int

proc value(x: string): Value =
  case x[0]
  of 'w'..'z': Value(kind: Reg, r: x[0].ord - 'w'.ord)
  else: Value(kind: Lit, v: x.parseInt)

proc parse(input: string): (seq[Instr], Prog) =
  var instrs: seq[Instr]
  for line in input.splitlines:
    case line.splitWhitespace
    of ["inp", @a]:     instrs.add(Instr(kind: Inp, a: a[0].ord - 'w'.ord))
    of ["add", @a, @b]: instrs.add(Instr(kind: Add, a: a[0].ord - 'w'.ord, b: value(b)))
    of ["mul", @a, @b]: instrs.add(Instr(kind: Mul, a: a[0].ord - 'w'.ord, b: value(b)))
    of ["div", @a, @b]: instrs.add(Instr(kind: Div, a: a[0].ord - 'w'.ord, b: value(b)))
    of ["mod", @a, @b]: instrs.add(Instr(kind: Mod, a: a[0].ord - 'w'.ord, b: value(b)))
    of ["eql", @a, @b]: instrs.add(Instr(kind: Eql, a: a[0].ord - 'w'.ord, b: value(b)))
    else: raiseAssert fmt"Invalid input: {line}"
  (instrs, Prog(regs: [0, 0, 0, 0], pc: 0))

proc val(p: var Prog, v: Value): int =
  case v.kind
  of Reg: p.regs[v.r]
  of Lit: v.v

proc runNext(p: var Prog, instrs: seq[Instr], inp: int): bool =
  var a = 0
  while p.pc < instrs.len:
    let instr = instrs[p.pc]
    case instr.kind
    of Inp: p.regs[instr.a] = inp
    of Add: p.regs[instr.a] += p.val(instr.b)
    of Mul: p.regs[instr.a] *= p.val(instr.b)
    of Div:
      if instr.a == 3 and instr.b.kind == Lit:
        a = instr.b.v
      p.regs[instr.a] = p.regs[instr.a] div p.val(instr.b)
    of Mod: p.regs[instr.a] = p.regs[instr.a] mod p.val(instr.b)
    of Eql: p.regs[instr.a] = int(p.regs[instr.a] == p.val(instr.b))
    p.pc += 1
    if p.pc < instrs.len and instrs[p.pc].kind == Inp:
      break
  doAssert a != 0
  a != 26 or p.regs[1] == 0

proc dfs(vis: var HashSet[Prog], instrs: seq[Instr], prog: Prog, n, d: int, p2: bool): Option[int] =
  if d == 0:
    return if prog.regs[3] == 0: some(n) else: none(int)
  if prog in vis:
    return none(int)
  let ds = if p2: (1..9).toSeq else: countdown(9, 1).toSeq
  for i in ds:
    var p = prog
    if not p.runNext(instrs, i):
      continue
    let ans = dfs(vis, instrs, p, n * 10 + i, d - 1, p2)
    if ans.isSome:
      return ans
  vis.incl(prog)

proc part1*(input: string): Option[int] =
  let (instrs, prog) = input.parse
  var s: HashSet[Prog]
  dfs(s, instrs, prog, 0, 14, false)

proc part2*(input: string): Option[int] =
  let (instrs, prog) = input.parse
  var s: HashSet[Prog]
  dfs(s, instrs, prog, 0, 14, true)
