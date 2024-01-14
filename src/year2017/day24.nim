import fusion/matching
import sequtils
import strutils
import sugar
import std/bitops
import std/enumerate
import std/packedsets

type
  Pipe = object
    id: uint8
    a: uint32
    b: uint32

  Bridge = object
    len: int
    strength: uint32
    port: uint32
    used: uint64

proc parsePipes(input: string): seq[Pipe] =
  for i, line in enumerate(0'u8, input.splitLines):
    [@a, @b] := line.split('/').map(parseInt)
    result.add Pipe(id: i, a: uint32(a), b: uint32(b))

proc fuse(b: Bridge, p: Pipe): Bridge =
  result = b
  inc result.len
  result.strength += p.a + p.b
  result.port = p.a + p.b - b.port
  result.used.setBit(p.id)

proc build[T](b: Bridge, key: (Bridge) -> T, neighbs: seq[seq[Pipe]], unusedSingles: var seq[int], visited: var PackedSet[uint64]): Bridge =
  var b = b
  if visited.containsOrIncl(b.used):
    return
  let port = b.port
  var singleIdx = none(uint32)
  if unusedSingles[port] > 0:
    singleIdx = some(port)
    dec unusedSingles[port]
    inc b.len
    b.strength += 2 * port
  result = b
  for p in neighbs[port]:
    if not b.used.testBit(p.id):
      let neighb = b.fuse(p).build(key, neighbs, unusedSingles, visited)
      if key(neighb) > key(result):
        result = neighb
  if singleIdx.isSome:
    inc unusedSingles[singleIdx.unsafeGet]

proc solve[T](input: string, key: (Bridge) -> T): uint32 =
  let pipes = input.parsePipes
  var mx: uint32
  for p in pipes:
    mx = max(mx, p.a)
    mx = max(mx, p.b)
  var neighbs = newSeqWith(int(mx) + 1, newSeq[Pipe]())
  var singles = newSeq[int](mx + 1)
  for pipe in pipes:
    if pipe.a != pipe.b:
      neighbs[pipe.a].add(pipe)
      neighbs[pipe.b].add(pipe)
    else:
      inc singles[pipe.a]
  var ints: PackedSet[uint64]
  Bridge().build(key, neighbs, singles, ints).strength

proc part1*(input: string): uint32 =
  input.solve((b) => b.strength)

proc part2*(input: string): uint32 =
  input.solve((b) => (b.len, b.strength))
