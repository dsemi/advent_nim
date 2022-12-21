import fusion/matching
import strutils
import sugar
import tables

import "../utils"

{.experimental: "caseStmtMacros".}

type
  MKind = enum Atom, Comp
  Op = enum Add, Sub, Mul, Div
  Monkey = ref object
    case kind: MKind
    of Atom: val: int
    of Comp:
      left, right: string
      op: Op
  Node = Either[(int) -> int, int]

proc eval(op: Op, left, right: int): int =
  case op
  of Add: left + right
  of Sub: left - right
  of Mul: left * right
  of Div: left div right

proc monkeys(input: string): Table[string, Monkey] =
  for line in input.splitLines:
    case line.splitWhitespace:
      of [@k, @n]: result[k[0..^2]] = Monkey(kind: Atom, val: n.parseInt)
      of [@k, @left, @op, @right]:
        result[k[0..^2]] = Monkey(kind: Comp, left: left, right: right, op: Op("+-*/".find(op[0])))

proc part1*(input: string): int =
  let ms = input.monkeys
  proc val(k: string): int =
    let m = ms[k]
    case m.kind
    of Atom: m.val
    of Comp: eval(m.op, m.left.val, m.right.val)
  val("root")

proc part2*(input: string): int =
  let ms = input.monkeys
  proc val(k: string): Node =
    if k == "humn":
      return Node(kind: EL, l: (x: int) => x)
    let m = ms[k]
    case m.kind
    of Atom: Node(kind: ER, r: m.val)
    of Comp:
      let left = m.left.val
      let right = m.right.val
      if left.kind == EL:
        case m.op
        of Add: Node(kind: EL, l: (n: int) => left.l(n - right.r))
        of Sub: Node(kind: EL, l: (n: int) => left.l(n + right.r))
        of Mul: Node(kind: EL, l: (n: int) => left.l(n div right.r))
        of Div: Node(kind: EL, l: (n: int) => left.l(n * right.r))
      elif right.kind == EL:
        case m.op
        of Add: Node(kind: EL, l: (n: int) => right.l(n - left.r))
        of Sub: Node(kind: EL, l: (n: int) => right.l(left.r - n))
        of Mul: Node(kind: EL, l: (n: int) => right.l(n div left.r))
        of Div: Node(kind: EL, l: (n: int) => right.l(left.r div n))
      else: Node(kind: ER, r: eval(m.op, left.r, right.r))
  let root = ms["root"]
  let lv = val(root.left)
  let rv = val(root.right)
  if lv.kind == EL: lv.l(rv.r)
  else: rv.l(lv.r)
