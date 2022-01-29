import bitops
import sets
import strscans
import strutils

type
  Pt = object
    c: array[3, int]

  Scanner = object
    ps: seq[Pt]
    offset: Pt
    min: Pt

proc min(a, b: Pt): Pt =
  Pt(c: [min(a.c[0], b.c[0]), min(a.c[1], b.c[1]), min(a.c[2], b.c[2])])

proc `<`(a, b: Pt): bool =
  (a.c[0], a.c[1], a.c[2]) < (b.c[0], b.c[1], b.c[2])

proc hash(a: Pt): uint64 =
  for n in a.c:
    result = (result shl 21) xor uint64(n)

proc add(s: var Scanner, p: Pt) =
  s.min = s.min.min(p)
  s.ps.add(p)

proc parse(input: string): seq[Scanner] =
  for group in input.split("\n\n"):
    result.add(Scanner())
    for line in group.splitlines[1..^1]:
      var pt: Pt
      doAssert line.scanf("$i,$i,$i", pt.c[0], pt.c[1], pt.c[2])
      result[^1].add(pt)

proc align(a, b: var Scanner, aa: int): bool =
  var collision = newSeq[uint8](4096 * 6)
  for pa in a.ps:
    for pb in b.ps:
      var base = 0
      for n in [2048 + (pb.c[0] - b.min.c[0]) - (pa.c[aa] - a.min.c[aa]),
                (pb.c[0] - b.min.c[0]) + (pa.c[aa] - a.min.c[aa]),
                2048 + (pb.c[1] - b.min.c[1]) - (pa.c[aa] - a.min.c[aa]),
                (pb.c[1] - b.min.c[1]) + (pa.c[aa] - a.min.c[aa]),
                2048 + (pb.c[2] - b.min.c[2]) - (pa.c[aa] - a.min.c[aa]),
                (pb.c[2] - b.min.c[2]) + (pa.c[aa] - a.min.c[aa])]:
        var n = n
        let idx = base + n
        inc collision[idx]
        if collision[idx] == 12:
          let ori = idx div 4096
          let axis = ori div 2
          let negate = ori mod 2 == 1
          n += b.min.c[axis]
          if negate:
            n += a.min.c[aa]
          else:
            n -= a.min.c[aa] + 2048

          b.offset.c[aa] = if negate: -n else: n

          if axis != aa:
            swap(b.min.c[aa], b.min.c[axis])
            for p in b.ps.mitems:
              swap(p.c[aa], p.c[axis])
          if negate:
            b.min.c[aa] = n - b.min.c[aa] - 2047
            for p in b.ps.mitems:
              p.c[aa] = n - p.c[aa]
          else:
            b.min.c[aa] = b.min.c[aa] - n
            for p in b.ps.mitems:
              p.c[aa] = p.c[aa] - n
          return true
        base += 4096

iterator bits(n: SomeInteger): int =
  var n = n
  while n != 0:
    yield n.countTrailingZeroBits
    n = n and (n - 1)

proc combine(input: string): (HashSet[uint64], seq[Scanner]) =
  var scanners = parse(input)
  var need = uint64(1) shl uint64(scanners.len) - 2
  var todo = @[0]
  while todo.len > 0:
    let i = todo.pop
    for j in need.bits:
      if align(scanners[i], scanners[j], 0):
        discard align(scanners[i], scanners[j], 1)
        discard align(scanners[i], scanners[j], 2)
        need = need xor (uint64(1) shl uint64(j))
        todo.add(j)
  for s in scanners:
    for p in s.ps:
      result[0].incl(p.hash)
  result[1] = scanners

proc part1*(input: string): int =
  combine(input)[0].len

proc part2*(input: string): int =
  let scanners = combine(input)[1]
  for a in scanners:
    for b in scanners:
      let dist = (abs(a.offset.c[0] - b.offset.c[0]) +
                  abs(a.offset.c[1] - b.offset.c[1]) +
                  abs(a.offset.c[2] - b.offset.c[2]))
      result = max(result, dist)
