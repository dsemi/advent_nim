from algorithm import reversed, sortedByIt
import re
import sequtils
import strutils
import sugar

import "../utils"

type Graph = ref object
  start: int
  flowRates: seq[uint8]
  workingValves: seq[int]
  dist: seq[seq[uint8]]

proc parse(input: string): Graph =
  let reg = re"Valve (\w+) has flow rate=(\d+); tunnels? leads? to valves? (.+)$"
  let ui = uniqueIdx()
  let valves = input.splitLines
  var dist = newSeqWith(valves.len, repeat(uint8.high, valves.len))
  var flowRates = newSeq[uint8](valves.len)
  for line in valves:
    if line =~ reg:
      let i = ui(matches[0])
      dist[i][i] = 0
      flowRates[i] = matches[1].parseInt.uint8
      for tunnel in matches[2].split(", "):
        let j = ui(tunnel)
        dist[i][j] = 1
  let workingValves = collect(for i, r in flowRates: (if r > 0: i)).sortedByIt(flowRates[it]).reversed
  # Floyd-Warshall
  for k in dist.low .. dist.high:
    for i in dist.low .. dist.high:
      for j in dist.low .. dist.high:
        dist[i][j] = if dist[i][k] == uint8.high or dist[k][j] == uint8.high:
                       dist[i][j]
                     else:
                       min(dist[i][j], dist[i][k] + dist[k][j])
  Graph(start: ui("AA"), flowRates: flowRates, workingValves: workingValves, dist: dist)

proc upperBound(g: Graph, openValves: uint16, pressure: uint16, timeLeft: uint8): uint16 =
  result = pressure
  var currT = timeLeft - 2
  for i, j in g.workingValves:
    if (openValves and (1'u16 shl i)) != 0:
      continue
    if currT <= 0:
      break
    let flow = g.flowRates[j]
    result += currT.uint16 * flow.uint16
    currT -= 2

proc dfs(g: Graph, res: var seq[uint16], i: int, openValves: uint16, pressure: uint16, timeLeft: uint8) =
  let upperBd = g.upperBound(openValves, pressure, timeLeft)
  let idx = openValves.int mod res.len
  if upperBd <= res[idx]:
    return
  res[idx] = max(res[idx], pressure)
  for bit, j in g.workingValves:
    let bit = 1'u16 shl bit
    if (bit and openValves) == 0 and g.dist[i][j] < timeLeft - 1:
      let timeLeft = timeLeft - g.dist[i][j] - 1
      g.dfs(res, j, openValves or bit, pressure + g.flowRates[j].uint16*timeLeft.uint16, timeLeft)

proc sim(g: Graph, time: uint8, bins: int): seq[uint16] =
  result = newSeq[uint16](bins)
  g.dfs(result, g.start, 0, 0, time)

proc part1*(input: string): uint16 =
  let graph = input.parse
  max(graph.sim(30, 1))

proc part2*(input: string): uint16 =
  let graph = input.parse
  var bestPressures = collect:
    for i, best in graph.sim(26, uint16.high.int):
      if best > 0:
        (i.uint16, best)
  bestPressures = bestPressures.sortedByIt(it[1]).reversed
  for i, (hOpens, hPressure) in bestPressures:
    for (eOpens, ePressure) in bestPressures[i+1..^1]:
      let p = hPressure + ePressure
      if p <= result:
        break

      if (hOpens and eOpens) == 0:
        result = p
