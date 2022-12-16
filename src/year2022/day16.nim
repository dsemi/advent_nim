import re
import sequtils
import strutils
import sugar
import tables

import "../utils"

type Graph = ref object
  flowRates: seq[int]
  workingValves: seq[int]
  dist: seq[seq[int]]

proc parse(input: string): (int, Graph) =
  let reg = re"Valve (\w+) has flow rate=(\d+); tunnels? leads? to valves? (.+)$"
  var ui = uniqueIdx()
  let valves = input.splitLines
  var dist = newSeqWith(valves.len, repeat(int.high, valves.len))
  var flowRates = newSeq[int](valves.len)
  for line in valves:
    if line =~ reg:
      let i = ui(matches[0])
      dist[i][i] = 0
      flowRates[i] = matches[1].parseInt
      for tunnel in matches[2].split(", "):
        let j = ui(tunnel)
        dist[i][j] = 1
  let workingValves = collect(for i, r in flowRates: (if r > 0: i))
  # Floyd-Warshall
  for k in dist.low .. dist.high:
    for i in dist.low .. dist.high:
      for j in dist.low .. dist.high:
        dist[i][j] = min(dist[i][j], dist[i][k] |+| dist[k][j])
  (ui("AA"), Graph(flowRates: flowRates, workingValves: workingValves, dist: dist))

iterator dfs(g: Graph, start: int, time: int): (uint64, int) =
  var stack = newSeq[(int, uint64, int, int)]()
  stack.add (start, 0'u64, 0, time)
  while stack.len > 0:
    let (i, openValves, relPressure, timeLeft) = stack.pop
    yield (openValves, relPressure)
    for j in g.workingValves:
      let bit = 1'u64 shl j
      if (bit and openValves) == 0 and g.dist[i][j] < timeLeft - 1:
        let timeLeft = timeLeft - g.dist[i][j] - 1
        stack.add (j, openValves or bit, relPressure + g.flowRates[j]*timeLeft, timeLeft)

proc part1*(input: string): int =
  let (start, graph) = input.parse
  for (_, pressure) in graph.dfs(start, 30):
    result = max(result, pressure)

proc part2*(input: string): int =
  let (start, graph) = input.parse
  var openToPress = initTable[uint64, int]()
  for (openValves, pressure) in graph.dfs(start, 26):
    openToPress[openValves] = max(openToPress.getOrDefault(openValves, 0), pressure)
  let bestPressures = toSeq(openToPress.pairs)
  for hi in 0 .. bestPressures.high:
    for ei in hi+1 .. bestPressures.high:
      let (hOpens, hPressure) = bestPressures[hi]
      let (eOpens, ePressure) = bestPressures[ei]
      if (hOpens and eOpens) == 0:
        result = max(result, hPressure + ePressure)
