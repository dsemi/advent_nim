import deques
import math
import options
import sequtils
import strutils
import sugar
import tables

type Queue = ref Deque[int]

type Program* = object
  mem: Table[int, int]
  ip*: int
  rb: int
  input*: Queue
  output*: Queue
  done*: bool

proc parse*(input: string): Program =
  let ns = input.split(',').map(parseInt)
  var mem: Table[int, int]
  for i, n in ns:
    mem[i] = n
  Program(mem: mem, input: new Queue, output: new Queue)

proc `[]`*(p: Program, k: int): int =
  if k in p.mem: p.mem[k]
  else: 0

proc `[]=`*(p: var Program, k: int, v: sink int) =
  p.mem[k] = v

type
  InstrKind = enum
    Add, Mul, Sav, Out, Jit, Jif, Lt, Eql, Arb, Hlt
  Mode = enum
    Pos, Imm, Rel
  Instr = object
    kind: InstrKind
    args: seq[int]

proc `[]`(instr: Instr, i: int): int =
  instr.args[i-1]

proc getArgs(prog: var Program, n: int): seq[int] =
  for i in 1..n:
    result &= (case Mode(prog[prog.ip] div 10^(i+1) mod 10):
                 of Pos: prog[prog.ip + i]
                 of Imm: prog.ip + i
                 of Rel: prog[prog.ip + i] + prog.rb)
  prog.ip += n + 1

proc parseInstr(prog: var Program): Instr =
  case prog[prog.ip] mod 100:
    of 1: Instr(kind: Add, args: prog.getArgs(3))
    of 2: Instr(kind: Mul, args: prog.getArgs(3))
    of 3: Instr(kind: Sav, args: prog.getArgs(1))
    of 4: Instr(kind: Out, args: prog.getArgs(1))
    of 5: Instr(kind: Jit, args: prog.getArgs(2))
    of 6: Instr(kind: Jif, args: prog.getArgs(2))
    of 7: Instr(kind: Lt, args: prog.getArgs(3))
    of 8: Instr(kind: Eql, args: prog.getArgs(3))
    of 9: Instr(kind: Arb, args: prog.getArgs(1))
    of 99: Instr(kind: Hlt)
    else: raiseAssert "Unknown op code: " & $prog[prog.ip]

proc send*(p: var Program, ins: openArray[int]) =
  for v in ins:
    p.input[].addLast(v)

iterator recv*(p: var Program): int =
  while p.output[].len > 0:
    yield p.output[].popFirst

proc recv*(p: var Program, n: int): Option[seq[int]] =
  if p.output[].len >= n:
    let res = collect(newSeq):
      for _ in 1..n:
        p.output[].popFirst
    return some(res)

proc hasOuts*(p: var Program, n: int): bool =
  p.output[].len >= n

proc run*(p: var Program) =
  doAssert not p.done
  while true:
    let instr = p.parseInstr
    case instr.kind:
      of Add: p[instr[3]] = p[instr[1]] + p[instr[2]]
      of Mul: p[instr[3]] = p[instr[1]] * p[instr[2]]
      of Sav:
        if p.input[].len == 0:
          p.ip -= 2
          break
        p[instr[1]] = p.input[].popFirst
      of Out: p.output[].addLast(p[instr[1]])
      of Jit:
        if p[instr[1]] != 0: p.ip = p[instr[2]]
      of Jif:
        if p[instr[1]] == 0: p.ip = p[instr[2]]
      of Lt: p[instr[3]] = int(p[instr[1]] < p[instr[2]])
      of Eql: p[instr[3]] = int(p[instr[1]] == p[instr[2]])
      of Arb: p.rb += p[instr[1]]
      of Hlt:
        p.done = true
        break

proc runNoIo*(p: Program, a, b: int): int =
  var p = p
  p[1] = a
  p[2] = b
  p.run
  p[0]

proc runIO*(p: var Program) =
  while true:
    p.run
    for v in p.recv:
      stdout.write(v.chr)
    if p.done:
      break
    p.send((stdin.readLine & "\n").mapIt(it.ord))
