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

proc eval(ms: TableRef[string, Monkey], k: string, p2: bool): Complex64 =
  if p2 and k == "humn":
    return im(1'f64)
  let m = ms[k]
  case m.kind
  of Num: m.v
  of Math:
    case m.op
    of Add: eval(ms, m.l, p2) + eval(ms, m.r, p2)
    of Sub: eval(ms, m.l, p2) - eval(ms, m.r, p2)
    of Mul: eval(ms, m.l, p2) * eval(ms, m.r, p2)
    of Div: eval(ms, m.l, p2) / eval(ms, m.r, p2)

proc part1*(input: string): int =
  input.monkeys.eval("root", false).re.int

proc part2*(input: string): int =
  let ms = input.monkeys
  let root = ms["root"]
  let l = ms.eval(root.l, true)
  let r = ms.eval(root.r, true)
  # We know the equation is linear
  int(if l.im != 0: (r.re - l.re) / l.im
      else: (l.re - r.re) / r.im)
