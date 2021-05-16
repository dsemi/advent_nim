import fusion/matching
import intsets
import options
import sequtils
import strutils

{.experimental: "caseStmtMacros".}

type
  Op = enum
    Addr, Addi, Mulr, Muli, Banr, Bani, Borr, Bori,
    Setr, Seti, Gtir, Gtri, Gtrr, Eqir, Eqri, Eqrr

  Instr = object
    op: Op
    a, b, c: int

proc parseInstrs(input: string): (int, seq[Instr]) =
  let lns = input.splitLines
  result[0] = lns[0].split[^1].parseInt
  for line in lns[1..^1]:
    [@cmd, all @rest] := line.splitWhitespace
    let op = case cmd:
               of "addr": Addr
               of "addi": Addi
               of "mulr": Mulr
               of "muli": Muli
               of "banr": Banr
               of "bani": Bani
               of "borr": Borr
               of "bori": Bori
               of "setr": Setr
               of "seti": Seti
               of "gtir": Gtir
               of "gtri": Gtri
               of "gtrr": Gtrr
               of "eqir": Eqir
               of "eqri": Eqri
               of "eqrr": Eqrr
               else: raiseAssert "Bad instr: " & line
    [@a, @b, @c] := rest.map(parseInt)
    result[1].add(Instr(op: op, a: a, b: b, c: c))

proc eval(v: var openArray[int], instr: Instr): Option[int] =
  let (a, b, c) = (instr.a, instr.b, instr.c)
  case instr.op:
    of Addr: v[c] = v[a] + v[b]
    of Addi: v[c] = v[a] + b
    of Mulr: v[c] = v[a] * v[b]
    of Muli: v[c] = v[a] * b
    of Banr: v[c] = v[a] and v[b]
    of Bani: v[c] = v[a] and b
    of Borr: v[c] = v[a] or v[b]
    of Bori: v[c] = v[a] or b
    of Setr: v[c] = v[a]
    of Seti: v[c] = a
    of Gtir: v[c] = int(a > v[b])
    of Gtri: v[c] = int(v[a] > b)
    of Gtrr: v[c] = int(v[a] > v[b])
    of Eqir: v[c] = int(a == v[b])
    of Eqri: v[c] = int(v[a] == b)
    of Eqrr:
      v[c] = int(v[a] == v[b])
      return some(v[a])

iterator run(prog: (int, seq[Instr])): int =
  var reg = [0, 0, 0, 0, 0, 0]
  let (ip, instrs) = prog
  while reg[ip] in instrs.low..instrs.high:
    if reg[ip] + 9 <= instrs.len:
      case instrs[reg[ip]..reg[ip]+8]:
        of [(op: Seti, a: 0, c: @t),
            (op: Addi, a: == t, b: 1, c: @u),
            (op: Muli, a: == u, b: @n, c: == u),
            (op: Gtrr, a: == u, b: @r, c: == u),
            (op: Addr, a: == u, b: == ip, c: == ip),
            (op: Addi, a: == ip, b: 1, c: == ip),
            (op: Seti, a: == (reg[ip]+8), c: == ip),
            (op: Addi, a: == t, b: == u, c: == t),
            (op: Seti, a: == reg[ip], c: == ip)]:
          reg[u] = 1
          reg[t] = max(0, reg[r] div n)
          reg[ip] += 9
          continue
    let x = reg.eval(instrs[reg[ip]])
    if x.isSome:
      yield x.get
    inc reg[ip]

proc part1*(input: string): int =
  for x in input.parseInstrs.run:
    return x

proc part2*(input: string): int =
  var s: IntSet
  var y = 0
  for x in input.parseInstrs.run:
    if x in s:
      return y
    s.incl(x)
    y = x
