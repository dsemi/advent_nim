import math
import sequtils
import strscans
import strutils

type LinearTrans = object
  a: int64
  b: int64
  modulus: int64

proc times(m, a, b: int64): int64 =
  var a = a
  var b = b
  while b > 0:
    if floorMod(b, 2) == 1:
      result = floorMod(result + a, m)
    a = floorMod(2 * a, m)
    b = floorDiv(b, 2)

proc `<>`(a, b: LinearTrans): LinearTrans =
  doAssert a.modulus == b.modulus
  LinearTrans(a: a.modulus.times(b.a, a.a),
              b: floorMod(a.modulus.times(b.a, a.b) + b.b, a.modulus),
              modulus: a.modulus)

proc parseTechs(input: string, modulus: int64): LinearTrans =
  var trans: seq[LinearTrans]
  for line in input.splitLines:
    var n: int
    if line == "deal into new stack":
      trans.add(LinearTrans(a: modulus - 1, b: modulus - 1, modulus: modulus))
    elif line.scanf("cut $i", n):
      trans.add(LinearTrans(a: 1, b: floorMod(-n.int64, modulus), modulus: modulus))
    else:
      doAssert line.scanf("deal with increment $i", n)
      trans.add(LinearTrans(a: floorMod(n.int64, modulus), b: 0, modulus: modulus))
  trans.foldl(a <> b)

proc modInv(a0, b0: int64): int64 =
  var (a, b, x0) = (a0, b0, 0.int64)
  result = 1
  if b == 1: return
  while a > 1:
    result = result - floorDiv(a, b) * x0
    a = floorMod(a, b)
    swap a, b
    swap x0, result
  if result < 0: result += b0

proc invert(t: LinearTrans): LinearTrans =
  let a = modInv(t.a, t.modulus)
  let b = t.modulus.times(-a, t.b)
  LinearTrans(a: a, b: b, modulus: t.modulus)

proc pow(t: LinearTrans, n: int64): LinearTrans =
  doAssert n != 0
  if n < 0:
    return t.invert.pow(-n)
  if n == 1:
    return t
  if floorMod(n, 2) == 0:
    return pow(t <> t, floorDiv(n, 2))
  return t <> pow(t, n - 1)

proc shuffle(t: LinearTrans, n, i: int64): int64 =
  let t2 = t.pow(n)
  floorMod(t2.a * i + t2.b, t.modulus)

proc part1*(input: string): int64 =
  let modulus = 10007
  input.parseTechs(modulus).shuffle(1, 2019)

proc part2*(input: string): int64 =
  let modulus = 119315717514047
  input.parseTechs(modulus).shuffle(-101741582076661, 2020)
