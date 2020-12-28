import algorithm
import sets
import strutils
import sugar

proc parse(input: string): seq[seq[int]] =
  collect(newSeq):
    for p in input.split("\n\n"):
      collect(newSeq):
        for x in p.splitlines[1 .. ^1]:
          x.parseInt

proc play(pa: seq[int], pb: seq[int], part2: bool = false, sub: bool = false): (int, bool) =
  if sub and pa.max > pb.max:
    return (0, true)
  var s = initHashSet[seq[int]]()
  var pa = pa
  var pb = pb
  while pa.len != 0 and pb.len != 0:
    if part2:
      if s.containsOrIncl(pa) or s.containsOrIncl(pb):
        return (0, true)
    let a = pa[0]
    pa.delete(0)
    let b = pb[0]
    pb.delete(0)
    if (if part2 and a <= pa.len and b <= pb.len: play(pa[0..<a], pb[0..<b], part2, true)[1] else: a > b):
      pa.add([a, b])
    else:
      pb.add([b, a])
  var sum = 0
  for i, x in (if pa.len > 0: pa else: pb).reversed:
    sum += (i + 1) * x
  return (sum, pb.len == 0)

proc part1*(input: string): int =
  let ns = parse(input)
  play(ns[0], ns[1])[0]

proc part2*(input: string): int =
  let ns = parse(input)
  play(ns[0], ns[1], true)[0]
