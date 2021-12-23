import algorithm
import deques
import heapqueue
import macros
import math
import options
import sequtils
import sets
import sugar
import tables

proc `//=`*(a: var SomeInteger, b: SomeInteger) =
  a = a div b

proc `%=`*(a: var SomeInteger, b: SomeInteger) =
  a = floorMod(a, b)

# Coordinates
type Coord* = tuple
  x: int
  y: int

proc `+`*(p1: Coord, p2: Coord): Coord =
  (p1.x + p2.x, p1.y + p2.y)

proc `+=`*(p1: var Coord, p2: Coord) =
  p1.x += p2.x
  p1.y += p2.y

proc `-`*(p1: Coord, p2: Coord): Coord =
  (p1.x - p2.x, p1.y - p2.y)

proc `*`*(n: int, p: Coord): Coord =
  (p.x * n, p.y * n)

proc `*`*(p1: Coord, p2: Coord): Coord =
  (p1.x * p2.x - p1.y * p2.y, p1.x * p2.y + p1.y * p2.x)

proc `*=`*(p1: var Coord, p2: Coord) =
  p1 = p1 * p2

proc abs*(p: Coord): Coord =
  (p.x.abs, p.y.abs)

proc sum*(p: Coord): int =
  p.x + p.y

proc sgn*(p: Coord): Coord =
  (p.x.sgn, p.y.sgn)

iterator countup*(a, b: Coord): Coord =
  for x in countup(a.x, b.x):
    for y in countup(a.y, b.y):
      yield (x, y)

type Coord3* = tuple
  x: int
  y: int
  z: int

proc `+`*(p1: Coord3, p2: Coord3): Coord3 =
  (p1.x + p2.x, p1.y + p2.y, p1.z + p2.z)

proc `+=`*(p1: var Coord3, p2: Coord3) =
  p1.x += p2.x
  p1.y += p2.y
  p1.z += p2.z

proc `-`*(c: Coord3): Coord3 =
  (-c.x, -c.y, -c.z)

proc `-`*(p1: Coord3, p2: Coord3): Coord3 =
  (p1.x - p2.x, p1.y - p2.y, p1.z - p2.z)

proc `*`*(n: int, p: Coord3): Coord3 =
  (p.x * n, p.y * n, p.z * n)

proc `div`*(c: Coord3, n: int): Coord3 =
  (c.x div n, c.y div n, c.z div n)

proc floorDiv*(c: Coord3, n: int): Coord3 =
  (floorDiv(c.x, n), floorDiv(c.y, n), floorDiv(c.z, n))

proc abs*(p: Coord3): Coord3 =
  (p.x.abs, p.y.abs, p.z.abs)

proc sum*(p: Coord3): int =
  p.x + p.y + p.z

iterator countup*(a, b: Coord3): Coord3 =
  for x in countup(a.x, b.x):
    for y in countup(a.y, b.y):
      for z in countup(a.z, b.z):
        yield (x, y, z)

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

proc chunks*[T](s: openArray[T], n: int): seq[seq[T]] =
  for i in countup(0, s.high, n):
    result.add(s[i..<i+n])

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

proc partitions*(n: int, t: int): iterator: seq[int] =
  result = iterator: seq[int] =
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

iterator dfs*[T](start: T, neighbors: T -> seq[T]): (int, T) =
  var visited = toHashSet([start])
  var frontier = @[(0, start)]
  while frontier.len > 0:
    let (d, st) = frontier.pop
    yield (d, st)
    for st2 in neighbors(st):
      if st2 notin visited:
        visited.incl(st2)
        frontier.add((d+1, st2))

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

proc aStar*[T](neighbors: T -> (iterator: T), dist: (T, T) -> int, heur: T -> int, goal: T -> bool, start: T): seq[T] =
  var visited = [start].toHashSet
  var queue = [(0, start)].toHeapQueue
  var cameFrom: Table[T, T]
  var gScore: Table[T, int]
  gScore[start] = 0
  var fScore: Table[T, int]
  fScore[start] = heur(start)
  while queue.len > 0:
    let (_, st) = queue.pop
    if goal(st):
      result = @[st]
      while result[^1] in cameFrom:
        result.add(cameFrom[result[^1]])
      result.reverse
      break
    visited.excl(st)
    for st2 in neighbors(st):
      let tentGScore = gScore.getOrDefault(st, int.high) + dist(st, st2)
      if tentGScore < gScore.getOrDefault(st2, int.high):
        cameFrom[st2] = st
        gScore[st2] = tentGScore
        fScore[st2] = gScore[st2] + heur(st2)
        if st2 notin visited:
          queue.push((fScore[st2], st2))
          visited.incl(st2)

proc seqToIter*[T](xs: seq[T]): iterator: T =
  return iterator(): T =
    for x in xs:
      yield x

# Macro for Nth?
iterator combos2*[T](xs: seq[T]): (T, T) =
  for i in xs.low..xs.high:
    for j in i+1..xs.high:
      yield (xs[i], xs[j])

type Tree*[T] = ref object
  val*: T
  children*: seq[Tree[T]]

proc map*[T, S](t: Tree[T], f: proc(x: T): S {.closure.}): Tree[S] {.inline.} =
  Tree[S](val: f(t.val),
          children: t.children.mapIt(it.map(f)))

proc fold*[T](t: Tree[T], f: proc(a: T, b: T): T {.closure.}, init: T): T {.inline.} =
  f(t.val, t.children.mapIt(it.fold(f, init)).foldl(f(a, b), init))

proc sum*(t: Tree[SomeInteger]): SomeInteger {.inline.} =
  t.val + t.children.mapIt(it.sum).sum

# Scanf utils

proc c*(input: string, charVal: var char, start: int): int =
  if start+1 <= input.len:
    charVal = input[start]
    return 1

proc first[T](a, b: T): T = a

proc intersect*[K, V](a, b: Table[K, V], f: (V, V) -> V = first): Table[K, V] =
  result = a
  for k in a.keys:
    if k notin b:
      result.del(k)
    else:
      result[k] = f(result[k], b[k])
