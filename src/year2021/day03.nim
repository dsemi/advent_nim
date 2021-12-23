import sequtils
import strutils
import sugar

proc part1*(input: string): int =
  let ns = input.splitlines.mapIt(it.toSeq)
  var gamma = 0
  for i in 0..<ns[0].len:
    var c = 0
    for n in ns:
      if n[i] == '1':
        inc c
    gamma = gamma shl 1 or int(c >= (ns.len + 1) div 2)
  gamma * ((1 shl ns[0].len - 1) xor gamma)

proc mostMatched(ns: seq[seq[char]], p: (int, int) -> bool): int =
  var ns = ns
  for i in 0..<ns[0].len:
    var o, z: seq[seq[char]]
    for n in ns:
      if n[i] == '1':
        o.add(n)
      else:
        z.add(n)
    ns = if p(o.len, z.len): o else: z
  ns[0].foldl(a shl 1 or (b.ord - '0'.ord), 0)

proc part2*(input: string): int =
  let ns = input.splitlines.mapIt(it.toSeq)
  mostMatched(ns, (a, b) => a >= b) * mostMatched(ns, (a, b) => a < b and a != 0 or b == 0)
