import complex
import strutils
import tables

type
  Op = enum Add, Sub, Mul, Div
  MKind = enum Num, Math
  Monkey = ref object
    case kind: MKind
    of Num: v: Complex64
    of Math:
      l, r: string
      op: Op

proc monkeys(input: string): TableRef[string, Monkey] =
  result = newTable[string, Monkey]()
  for line in input.splitLines:
    let pts = line.splitWhitespace
    result[pts[0][0..^2]] =
      if pts.len == 2: Monkey(kind: Num, v: complex64(pts[1].parseInt.float64, 0))
      else: Monkey(kind: Math, l: pts[1], op: Op("+-*/".find(pts[2][0])), r: pts[3])

proc eval(ms: TableRef[string, Monkey], k: string): Complex64 =
  let m = ms[k]
  case m.kind
  of Num: m.v
  of Math:
    case m.op
    of Add: eval(ms, m.l) + eval(ms, m.r)
    of Sub: eval(ms, m.l) - eval(ms, m.r)
    of Mul: eval(ms, m.l) * eval(ms, m.r)
    of Div: eval(ms, m.l) / eval(ms, m.r)

proc part1*(input: string): int =
  input.monkeys.eval("root").re.int

proc part2*(input: string): int =
  var ms = input.monkeys
  # We know the equation is linear
  ms["root"].op = Sub
  ms["humn"] = Monkey(kind: Num, v: complex64(0, 1))
  let n = ms.eval("root")
  -int(n.re / n.im)
