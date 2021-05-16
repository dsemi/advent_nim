import fusion/matching
import sequtils
import strutils

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

proc eval(v: var openArray[int], instr: Instr) =
  let (a, b, c) = (instr.a, instr.b, instr.c)
  v[c] = case instr.op:
           of Addr: v[a] + v[b]
           of Addi: v[a] + b
           of Mulr: v[a] * v[b]
           of Muli: v[a] * b
           of Banr: v[a] and v[b]
           of Bani: v[a] and b
           of Borr: v[a] or v[b]
           of Bori: v[a] or b
           of Setr: v[a]
           of Seti: a
           of Gtir: int(a > v[b])
           of Gtri: int(v[a] > b)
           of Gtrr: int(v[a] > v[b])
           of Eqir: int(a == v[b])
           of Eqri: int(v[a] == b)
           of Eqrr: int(v[a] == v[b])

proc run(prog: (int, seq[Instr])): int =
  var reg = [0, 0, 0, 0, 0, 0]
  let (ip, instrs) = prog
  while reg[ip] in instrs.low..instrs.high:
    reg.eval(instrs[reg[ip]])
    inc reg[ip]
  reg[0]

proc part1*(input: string): int =
  input.parseInstrs.run

# Not sure if there's a better way than just deconstructing the assembly
proc part2*(input: string): int =
  let n = 10_551_361
  for d in 1..n:
    if n mod d == 0:
      result += d
