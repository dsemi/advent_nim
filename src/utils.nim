import algorithm
import bitops
import deques
import heapqueue
import macros
import math
import options
import sequtils
import sets
import strutils
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

proc scale*(p: Coord, n: int): Coord =
  (n * p.x, n * p.y)

iterator countup*(a, b: Coord): Coord =
  for x in countup(a.x, b.x):
    for y in countup(a.y, b.y):
      yield (x, y)

proc `[]`*[T](grid: openArray[seq[T]], c: Coord): T {.inline.} =
  grid[c.x][c.y]

proc `[]`*[T](grid: var openArray[seq[T]], c: Coord): var T {.inline.} =
  grid[c.x][c.y]

proc `[]=`*[T](grid: var openArray[seq[T]], c: Coord, v: T) {.inline.} =
  grid[c.x][c.y] = v

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

proc abs*(p: Coord3): Coord3 =
  (p.x.abs, p.y.abs, p.z.abs)

proc sum*(p: Coord3): int =
  p.x + p.y + p.z

proc min*(a, b: Coord3): Coord3 =
  (min(a.x, b.x), min(a.y, b.y), min(a.z, b.z))

proc max*(a, b: Coord3): Coord3 =
  (max(a.x, b.x), max(a.y, b.y), max(a.z, b.z))

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

iterator partitions*(n: int, t: int): seq[int] =
  var ns = newSeq[int](n)
  ns[^1] = t
  while true:
    yield ns
    if ns[0] == t:
      break
    for i in countdown(ns.high, 1):
      if ns[i] > 0:
        let og = ns[i]
        inc ns[i-1]
        for j in i ..< ns.high:
          ns[j] = 0
        ns[^1] = og - 1
        break

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

iterator bfsM*[T](starts: openArray[T], neighbors: T -> (iterator: T)): (int, T) =
  var visited = toHashSet(starts)
  var frontier = toDeque(collect(for start in starts: (0, start)))
  while frontier.len > 0:
    let (d, st) = frontier.popFirst
    yield (d, st)
    for st2 in neighbors(st):
      if st2 notin visited:
        visited.incl(st2)
        frontier.addLast((d+1, st2))

iterator bfs*[T](start: T, neighbors: T -> (iterator: T)): (int, T) =
  for x in bfsM(@[start], neighbors):
    yield x

iterator dijkstra*[T](start: T, neighbs: T -> (iterator: (int, T))): (int, T) =
  var dists: Table[T, int]
  var queue = [(0, start)].toHeapQueue
  while queue.len > 0:
    let (d, st) = queue.pop
    yield (d, st)
    if d <= dists.getOrDefault(st, int.high):
      dists[st] = d
      for (d2, st2) in neighbs(st):
        let dist = d + d2
        if dist < dists.getOrDefault(st2, dist + 1):
          dists[st2] = dist
          queue.push((dist, st2))

iterator dijkstra*[T](start: T, neighbs: T -> seq[(int, T)]): (int, T) =
 for x in dijkstra(start, proc(s: T): iterator(): (int, T) =
                            return iterator(): (int, T) =
                              for n in neighbs(s):
                                yield n):
   yield x

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

iterator combos*[T](xs: seq[T], n: int): seq[T] =
  var buf = newSeq[T](n)
  var c = newSeq[int](n)
  for i in 0 ..< n:
    c[i] = i
    buf[i] = xs[i]

  block outer:
    while true:
      yield buf

      var i = n - 1
      inc c[i]
      if c[i] < xs.len:
        buf[i] = xs[c[i]]
        continue

      while c[i] >= xs.len - n + i:
        dec i
        if i < 0:
          break outer
      inc c[i]
      buf[i] = xs[c[i]]
      while i < n-1:
        c[i+1] = c[i] + 1
        buf[i+1] = xs[c[i+1]]
        inc i

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

proc first[T](a, b: T): T = a

proc intersect*[K, V](a, b: Table[K, V], f: (V, V) -> V = first): Table[K, V] =
  result = a
  for k in a.keys:
    if k notin b:
      result.del(k)
    else:
      result[k] = f(result[k], b[k])

iterator bits*(n: SomeInteger): int =
  var n = n
  while n > 0:
    yield n.countTrailingZeroBits
    n = n and (n - 1)

type Interval*[T] = object
  lo*, hi*: T

proc intersects*[T](a, b: Interval[T]): bool =
  a.lo < b.hi and b.lo < a.hi

proc intersect*[T](a, b: Interval[T]): Interval[T] =
  Interval[T](lo: max(a.lo, b.lo), hi: min(a.hi, b.hi))

proc union*[T](a, b: Interval[T]): Interval[T] =
  Interval[T](lo: min(a.lo, b.lo), hi: max(a.hi, b.hi))

proc len*[T](a: Interval[T]): T =
  a.hi - a.lo

proc uniqueIdx*(): proc(k: string): int =
  var m = initTable[string, int]()
  var cnt = 0
  return proc(k: string): int =
    if not m.hasKeyOrPut(k, cnt):
      inc cnt
    m[k]

proc `|+|`*(a, b: int): int =
  ## saturated addition.
  result = a +% b
  if (result xor a) >= 0'i64 or (result xor b) >= 0'i64:
    return result
  if a < 0 or b < 0:
    result = low(typeof(result))
  else:
    result = high(typeof(result))
