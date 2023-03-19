import fusion/matching
import strutils
import sugar
import tables

type Reactions = ref object
  graph: Table[string, (int64, seq[(int64, string)])]
  topo: seq[string]

proc parseReactions(input: string): Reactions =
  var graph = initTable[string, (int64, seq[(int64, string)])]()
  for line in input.splitLines:
    [@ins, @outp] := line.split(" => ")
    let inps = collect(newSeq):
      for inp in ins.split(", "):
        [@n, @elem] := inp.split
        (n.parseBiggestInt, elem)
    [@n, @elem] := outp.split
    graph[elem] = (n.parseBiggestInt, inps)
  var incoming = initCountTable[string]()
  for (_, srcs) in graph.values:
    for (_, src) in srcs:
      incoming.inc(src)
  var topo = newSeq[string]()
  var noIncoming = @["FUEL"]
  while noIncoming.len > 0:
    let e = noIncoming.pop
    if e in graph:
      topo.add(e)
      for (_, m) in graph[e][1]:
        incoming[m] = incoming[m] - 1
        if incoming[m] == 0:
          noIncoming.add(m)
  Reactions(graph: graph, topo: topo)

proc numOre(reactions: Reactions, n: int64): int64 =
  var cnts = initCountTable[string]()
  cnts.inc("FUEL", n.int)
  for e in reactions.topo:
    let (n, srcs) = reactions.graph[e]
    let k = (cnts[e] + n - 1) div n
    for (n, m) in srcs:
      cnts.inc(m, int(k * n))
  cnts["ORE"]

proc part1*(input: string): int64 =
  input.parseReactions.numOre(1)

const trillion = 1_000_000_000_000

proc part2*(input: string): int64 =
  let reactions = input.parseReactions
  var (a, b) = (0.int64, trillion)
  while a < b:
    let mid = (a + b) div 2
    if reactions.numOre(mid) > trillion:
      b = mid - 1
    else:
      a = mid + 1
  if reactions.numOre(a) > trillion: a - 1 else: a
