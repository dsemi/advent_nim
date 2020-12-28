import sequtils
import strutils

proc part1*(input: string): int =
  let ns = input.splitlines.map(parseInt)
  for i in ns.low .. ns.high:
    for j in i+1 .. ns.high:
      if ns[i] + ns[j] == 2020:
        return ns[i] * ns[j]

proc part2*(input: string): int =
  let ns = input.splitlines.map(parseInt)
  for i in ns.low .. ns.high:
    for j in i+1 .. ns.high:
      for k in j+1 .. ns.high:
        if ns[i] + ns[j] + ns[k] == 2020:
          return ns[i] * ns[j] * ns[k]
