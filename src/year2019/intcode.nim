import math
import sequtils
import strutils
import tables

type Memory = CountTable[int]

proc parse*(input: string): Memory =
  let ns = input.split(',').map(parseInt)
  for i, n in ns:
    result[i] = n

type
  InstrKind = enum
    Add, Mul, Sav, Out, Jit, Jif, Lt, Eql, Arb, Hlt
  Mode = enum
    Pos, Imm, Rel
  Instr[T] = object
    kind: InstrKind
    args: seq[T]

proc getArgs(mem: var Memory, idx: var int, n: int): seq[(Mode, int)] =
  for i in 1..n:
    result &= (Mode(mem[idx] div 10^(i+1) mod 10), idx + i)
  idx += n + 1

proc parseInstr(mem: var Memory, idx: var int): Instr[(Mode, int)] =
  case mem[idx] mod 100:
    of 1:
      result = Instr[(Mode, int)](kind: Add, args: mem.getArgs(idx, 3))
    of 2:
      result = Instr[(Mode, int)](kind: Mul, args: mem.getArgs(idx, 3))
    of 3:
      result = Instr[(Mode, int)](kind: Sav, args: mem.getArgs(idx, 1))
    of 4:
      result = Instr[(Mode, int)](kind: Out, args: mem.getArgs(idx, 1))
    of 5:
      result = Instr[(Mode, int)](kind: Jit, args: mem.getArgs(idx, 2))
    of 6:
      result = Instr[(Mode, int)](kind: Jif, args: mem.getArgs(idx, 2))
    of 7:
      result = Instr[(Mode, int)](kind: Lt, args: mem.getArgs(idx, 3))
    of 8:
      result = Instr[(Mode, int)](kind: Eql, args: mem.getArgs(idx, 3))
    of 9:
      result = Instr[(Mode, int)](kind: Arb, args: mem.getArgs(idx, 1))
    of 99:
      result = Instr[(Mode, int)](kind: Hlt)
    else: raiseAssert "Unknown op code: " & $mem[idx]

proc run(mem: var Memory) =
  var idx = 0
  var rb = 0
  while true:
    let instr = mem.parseInstr(idx)
    let args = instr.args.mapIt(case it[0]:
                                  of Pos: mem[it[1]]
                                  of Imm: it[1]
                                  of Rel: mem[it[1]] + rb)
    case instr.kind:
      of Add: mem[args[2]] = mem[args[0]] + mem[args[1]]
      of Mul: mem[args[2]] = mem[args[0]] * mem[args[1]]
      of Sav: discard
      of Out: discard
      of Jit:
        if mem[args[0]] != 0: idx = mem[args[1]]
      of Jif:
        if mem[args[0]] == 0: idx = mem[args[1]]
      of Lt: mem[args[2]] = int(mem[args[0]] < mem[args[1]])
      of Eql: mem[args[2]] = int(mem[args[0]] == mem[args[1]])
      of Arb: rb += mem[args[0]]
      of Hlt: break

proc runNoIo*(mem: Memory, a, b: int): int =
  var mem = mem
  mem[1] = a
  mem[2] = b
  mem.run
  mem[0]
