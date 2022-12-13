import algorithm
import sequtils
import std/enumerate
import streams
import strutils

type
  pKind = enum
    pLit,
    pList
  Packet = ref object
    case kind: pKind
    of pLit: val: int
    of pList: vals: seq[Packet]

proc parse(line: StringStream): Packet =
  if line.peekChar == '[':
    result = Packet(kind: pList)
    discard line.readChar
    while line.peekChar != ']':
      result.vals.add(line.parse)
      if line.peekChar == ',': discard line.readChar
    discard line.readChar
  else:
    var n = 0
    while line.peekChar in '0'..'9':
      n = n * 10 + line.readChar.ord - '0'.ord
    result = Packet(kind: pLit, val: n)

proc cmp(a, b: Packet): int =
  if a.kind == pLit and b.kind == pLit:
    return cmp(a.val, b.val)
  elif a.kind == pList and b.kind == pList:
    for i in 0 .. min(a.vals.high, b.vals.high):
      let c = cmp(a.vals[i], b.vals[i])
      if c != 0: return c
    return cmp(a.vals.len, b.vals.len)
  elif a.kind == pList and b.kind == pLit:
    return cmp(a, Packet(kind: pList, vals: @[b]))
  elif a.kind == pLit and b.kind == pList:
    return cmp(Packet(kind: pList, vals: @[a]), b)

proc `==`(a, b: Packet): bool =
  cmp(a, b) == 0

proc part1*(input: string): int =
  for i, packets in enumerate(1, input.split("\n\n")):
    let pkts = packets.splitLines.mapIt(it.newStringStream.parse)
    if cmp(pkts[0], pkts[1]) < 0:
      result += i

proc part2*(input: string): int =
  let a = "[[2]]".newStringStream.parse
  let b = "[[6]]".newStringStream.parse
  var pkts = @[a, b]
  for packets in input.split("\n\n"):
    pkts.add packets.splitLines.mapIt(it.newStringStream.parse)
  pkts.sort(cmp = cmp)
  (pkts.find(a) + 1) * (pkts.find(b) + 1)
