import math
import sequtils

proc `//=`*(a: var SomeInteger, b: SomeInteger) =
  a = a div b

# Coordinates
type Coord* = tuple
  x: int
  y: int

proc `+`*(p1: Coord, p2: Coord): Coord =
  (p1.x + p2.x, p1.y + p2.y)

proc `+=`*(p1: var Coord, p2: Coord) =
  p1.x += p2.x
  p1.y += p2.y

proc `*`*(n: int, p: Coord): Coord =
  (p.x * n, p.y * n)

proc `*`*(p1: Coord, p2: Coord): Coord =
  (p1.x * p2.x - p1.y * p2.y, p1.x * p2.y + p1.y * p2.x)

proc `*=`*(p1: var Coord, p2: Coord) =
  (p1.x, p1.y) = (p1.x * p2.x - p1.y * p2.y, p1.x * p2.y + p1.y * p2.x)

# Could add exp by squaring but likely not noticeable
proc `^`*(p: Coord, n: int): Coord =
  if n == 1:
    return p
  p * p^(n-1)

# Math
proc powMod*(a: int, b: int, m: int): int =
  if b == 0:
    return 1
  if b mod 2 == 0:
    return powMod(a * a mod m, b div 2, m)
  return a * powMod(a, b - 1, m) mod m

proc mulInv(a: int, b0: int): int =
  var a = a
  var b = b0
  var (x0, x1) = (0, 1)
  if b == 1:
    return 1
  while a > 1:
    let q = a div b
    (a, b) = (b, floorMod(a, b))
    (x0, x1) = (x1 - q * x0, x0)
  if x1 < 0:
    x1 += b0
  return x1

proc chineseRemainder*(an: seq[(int, int)]): int =
  var sum = 0
  let prod = an.mapIt(it[1]).foldl(a * b)
  for (a_i, n_i) in an:
    let p = prod div n_i
    sum += a_i * mulInv(p, n_i) * p
  floorMod(sum, prod)

proc transpose*[T](s: seq[seq[T]]): seq[seq[T]] =
  result = newSeq[seq[T]](s[0].len)
  for i in 0 ..< s[0].len:
    result[i] = newSeq[T](s.len)
    for j in 0 ..< s.len:
      result[i][j] = s[j][i]

# Closure iterator might be better here
proc partitions*(n: int, t: int): seq[seq[int]] =
  if n == 1:
    return @[@[t]]
  for x in 0..t:
    for xs in partitions(n-1, t-x):
      result.add(@[x] & xs)
