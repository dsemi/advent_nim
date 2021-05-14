import algorithm
import sequtils
import strutils
import sugar
import tables
import unpack

type Op = enum
  Addr, Addi, Mulr, Muli, Banr, Bani, Borr, Bori,
  Setr, Seti, Gtir, Gtri, Gtrr, Eqir, Eqri, Eqrr

proc eval(v: var openArray[int], op: Op, a, b, c: int) =
  v[c] = case op:
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

proc testSample(sample: string): (int, set[Op]) =
  [before, instr, after] <- sample.splitLines
  [op, a, b, c] <- instr.split.map(parseInt)
  let mem1 = before.split('[')[1][0..^2].split(", ").map(parseInt)
  let mem2 = after.split('[')[1][0..^2].split(", ").map(parseInt)
  result[0] = op
  for cmd in Op.low..Op.high:
    if mem1.dup(eval(cmd, a, b, c)) == mem2:
      result[1].incl(cmd)

proc part1*(input: string): int =
  for sample in input.split("\n\n")[0..^3]:
    if sample.testSample[1].card >= 3:
      inc result

proc determineOpCodes(m: var Table[int, set[Op]]): Table[int, Op] =
  while not toSeq(m.values).allIt(it.card == 1):
    for poss in toSeq(m.values).filterIt(it.card == 1):
      for p in poss:
        for v in m.mvalues:
          if v.card != 1:
            v.excl(p)
  collect(initTable):
    for (k, v) in m.pairs:
      {k: toSeq(v.items)[0]}

proc part2*(input: string): int =
  [prog, _, *samples] <- input.split("\n\n").reversed
  var m: Table[int, set[Op]]
  for sample in samples:
    let (k, v) = sample.testSample
    if k in m:
      m[k].incl(v)
    else:
      m[k] = v
  let ops = m.determineOpCodes
  var mem = [0, 0, 0, 0]
  for line in prog.splitLines:
    [op, a, b, c] <- line.split.map(parseInt)
    mem.eval(ops[op], a, b, c)
  mem[0]
