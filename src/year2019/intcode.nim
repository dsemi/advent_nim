import deques
import math
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
  Instr[T] = object
    kind: InstrKind
    args: seq[T]

proc getArgs(prog: var Program, n: int): seq[(Mode, int)] =
  for i in 1..n:
    result &= (Mode(prog[prog.ip] div 10^(i+1) mod 10), prog.ip + i)
  prog.ip += n + 1

proc parseInstr(prog: var Program): Instr[(Mode, int)] =
  case prog[prog.ip] mod 100:
    of 1: Instr[(Mode, int)](kind: Add, args: prog.getArgs(3))
    of 2: Instr[(Mode, int)](kind: Mul, args: prog.getArgs(3))
    of 3: Instr[(Mode, int)](kind: Sav, args: prog.getArgs(1))
    of 4: Instr[(Mode, int)](kind: Out, args: prog.getArgs(1))
    of 5: Instr[(Mode, int)](kind: Jit, args: prog.getArgs(2))
    of 6: Instr[(Mode, int)](kind: Jif, args: prog.getArgs(2))
    of 7: Instr[(Mode, int)](kind: Lt, args: prog.getArgs(3))
    of 8: Instr[(Mode, int)](kind: Eql, args: prog.getArgs(3))
    of 9: Instr[(Mode, int)](kind: Arb, args: prog.getArgs(1))
    of 99: Instr[(Mode, int)](kind: Hlt)
    else: raiseAssert "Unknown op code: " & $prog[prog.ip]

proc run*(p: var Program) =
  doAssert not p.done
  while true:
    let instr = p.parseInstr
    let args = instr.args.mapIt(case it[0]:
                                  of Pos: p[it[1]]
                                  of Imm: it[1]
                                  of Rel: p[it[1]] + p.rb)
    case instr.kind:
      of Add: p[args[2]] = p[args[0]] + p[args[1]]
      of Mul: p[args[2]] = p[args[0]] * p[args[1]]
      of Sav:
        if p.input[].len == 0:
          p.ip -= 2
          break
        p[args[0]] = p.input[].popFirst
      of Out: p.output[].addLast(p[args[0]])
      of Jit:
        if p[args[0]] != 0: p.ip = p[args[1]]
      of Jif:
        if p[args[0]] == 0: p.ip = p[args[1]]
      of Lt: p[args[2]] = int(p[args[0]] < p[args[1]])
      of Eql: p[args[2]] = int(p[args[0]] == p[args[1]])
      of Arb: p.rb += p[args[0]]
      of Hlt:
        p.done = true
        break

proc runIO*(p: var Program) =
  while true:
    p.run
    while p.output[].len > 0:
      let v = p.output[].popFirst
      stdout.write(v.chr)
    if p.done:
      break
    let cmd = stdin.readLine
    for c in cmd:
      p.input[].addLast(c.ord)
    p.input[].addLast('\n'.ord)
