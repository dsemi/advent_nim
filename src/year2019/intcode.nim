import math
import sequtils
import strutils
import sugar
import tables

type Memory = Table[int, int]

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

type
  ActionKind = enum
    Input, Output, Halt
  Action = object
    case kind: ActionKind
    of Input: f: (int) -> void
    of Output: v: int
    of Halt: n: int

proc run(mem: Memory): iterator: Action =
  return iterator(): Action =
    var mem = mem
    var idx = 0
    var rb = 0
    while true:
      let instr = mem.parseInstr(idx)
      let args = instr.args.mapIt(case it[0]:
                                    of Pos: mem.getOrDefault(it[1], 0)
                                    of Imm: it[1]
                                    of Rel: mem.getOrDefault(it[1], 0) + rb)
      case instr.kind:
        of Add: mem[args[2]] = mem.getOrDefault(args[0], 0) + mem.getOrDefault(args[1], 0)
        of Mul: mem[args[2]] = mem.getOrDefault(args[0], 0) * mem.getOrDefault(args[1], 0)
        of Sav:
          var x = 0
          yield Action(kind: Input, f: (y: int) => (x = y))
          mem[args[0]] = x
        of Out: yield Action(kind: Output, v: mem.getOrDefault(args[0], 0))
        of Jit:
          if mem.getOrDefault(args[0], 0) != 0: idx = mem.getOrDefault(args[1], 0)
        of Jif:
          if mem.getOrDefault(args[0], 0) == 0: idx = mem.getOrDefault(args[1], 0)
        of Lt: mem[args[2]] = int(mem.getOrDefault(args[0], 0) < mem.getOrDefault(args[1], 0))
        of Eql: mem[args[2]] = int(mem.getOrDefault(args[0], 0) == mem.getOrDefault(args[1], 0))
        of Arb: rb += mem.getOrDefault(args[0], 0)
        of Hlt:
          yield Action(kind: Halt, n: mem[0])
          break

proc runNoIo*(mem: Memory, a, b: int): int =
  var mem = mem
  mem[1] = a
  mem[2] = b
  for a in mem.run:
    result = a.n

proc runWithInput*(mem: Memory, input: openArray[int]): seq[int] =
  var i = 0
  for action in mem.run:
    case action.kind:
      of Input:
        action.f(input[i])
        inc i
      of Output: result.add(action.v)
      of Halt: discard
