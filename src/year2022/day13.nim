import algorithm
import json
import sequtils
import std/enumerate
import strutils

proc cmp(a, b: JsonNode): int =
  if a.kind == JInt and b.kind == JInt:
    return cmp(a.num, b.num)
  elif a.kind == JInt and b.kind == JArray:
    return cmp(JsonNode(kind: JArray, elems: @[a]), b)
  elif a.kind == JArray and b.kind == JInt:
    return cmp(a, JsonNode(kind: JArray, elems: @[b]))
  elif a.kind == JArray and b.kind == JArray:
    for i in 0 .. min(a.elems.high, b.elems.high):
      let c = cmp(a.elems[i], b.elems[i])
      if c != 0: return c
    return cmp(a.elems.len, b.elems.len)

proc part1*(input: string): int =
  for i, packets in enumerate(1, input.split("\n\n")):
    let pkts = packets.splitLines.mapIt(it.parseJson)
    if cmp(pkts[0], pkts[1]) < 0:
      result += i

proc part2*(input: string): int =
  let a = "[[2]]".parseJson
  let b = "[[6]]".parseJson
  var pkts = @[a, b]
  for packets in input.split("\n\n"):
    pkts.add packets.splitLines.mapIt(it.parseJson)
  pkts.sort(cmp = cmp)
  (pkts.find(a) + 1) * (pkts.find(b) + 1)
