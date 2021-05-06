import deques
import macros
import math
import options
import sequtils
import sets
import sugar

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

type Coord3* = tuple
  x: int
  y: int
  z: int

proc `+`*(p1: Coord3, p2: Coord3): Coord3 =
  (p1.x + p2.x, p1.y + p2.y, p1.z + p2.z)

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
  let cols = s.mapIt(it.len).max
  result = newSeq[seq[T]](cols)
  for i in 0 ..< cols:
    for j in 0 ..< s.len:
      if i < s[j].len:
        result[i].add(s[j][i])

macro toItr*(x: ForLoopStmt): untyped =
  ## Convert factory proc call for inline-iterator-like usage.
  ## E.g.: ``for e in toItr(myFactory(parm)): echo e``.
  let expr = x[0]
  let call = x[1][1] # Get foo out of toItr(foo)
  let body = x[2]
  result = quote do:
    block:
      let itr = `call`
      for `expr` in itr():
        `body`

proc partitions*(n: int, t: int): iterator(): seq[int] =
  result = iterator(): seq[int] =
    if n == 1:
      yield @[t]
    else:
      for x in 0..t:
        for xs in toItr(partitions(n-1, t-x)):
          yield @[x] & xs

proc lazy*[T](f: proc(): T): proc(): T =
  var val = none(T)
  return proc(): T =
           if val.isNone:
             val = some(f())
           val.get

proc force*[T](f: proc(): T): T = f()

iterator bfs*[T](start: T, neighbors: T -> (iterator: T)): (int, T) =
  var visited = toHashSet([start])
  var frontier = toDeque([(0, start)])
  while frontier.len > 0:
    let (d, st) = frontier.popFirst
    yield (d, st)
    for st2 in neighbors(st):
      if st2 notin visited:
        visited.incl(st2)
        frontier.addLast((d+1, st2))
