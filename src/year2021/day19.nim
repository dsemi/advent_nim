import bitops
import sets
import strscans
import strutils

type
  Pt = array[3, int]

  Scanner = object
    ps: seq[Pt]
    offset: Pt
    min: Pt

proc hash(a: Pt): uint64 =
  uint64(a[0] shl 42) xor uint64(a[1] shl 21) xor uint64(a[2])

proc add(s: var Scanner, p: Pt) =
  s.min = [min(s.min[0], p[0]), min(s.min[1], p[1]), min(s.min[2], p[2])]
  s.ps.add(p)

proc parse(input: string): seq[Scanner] =
  for group in input.split("\n\n"):
    result.add(Scanner())
    for line in group.splitlines[1..^1]:
      var pt: Pt
      doAssert line.scanf("$i,$i,$i", pt[0], pt[1], pt[2])
      result[^1].add(pt)

proc align(a, b: var Scanner, aa: static[int]): bool =
  var collision = newSeq[uint8](4096 * 6)
  for pa in a.ps:
    for pb in b.ps:
      var base = 0
      for n in [2048 + (pb[0] - b.min[0]) - (pa[aa] - a.min[aa]),
                (pb[0] - b.min[0]) + (pa[aa] - a.min[aa]),
                2048 + (pb[1] - b.min[1]) - (pa[aa] - a.min[aa]),
                (pb[1] - b.min[1]) + (pa[aa] - a.min[aa]),
                2048 + (pb[2] - b.min[2]) - (pa[aa] - a.min[aa]),
                (pb[2] - b.min[2]) + (pa[aa] - a.min[aa])]:
        var n = n
        let idx = base + n
        inc collision[idx]
        if collision[idx] == 12:
          let ori = idx div 4096
          let axis = ori div 2
          let negate = ori mod 2 == 1
          n += b.min[axis] + (if negate: a.min[aa] else: - a.min[aa] - 2048)

          b.offset[aa] = if negate: -n else: n

          if axis != aa:
            swap(b.min[aa], b.min[axis])
            for p in b.ps.mitems:
              swap(p[aa], p[axis])
          if negate:
            b.min[aa] = n - b.min[aa] - 2047
            for p in b.ps.mitems:
              p[aa] = n - p[aa]
          else:
            b.min[aa] = b.min[aa] - n
            for p in b.ps.mitems:
              p[aa] = p[aa] - n
          return true
        base += 4096

iterator bits(n: SomeInteger): int =
  var n = n
  while n != 0:
    yield n.countTrailingZeroBits
    n = n and (n - 1)

proc combine(input: string): (HashSet[uint64], seq[Scanner]) =
  var scanners = parse(input)
  var need = (uint64(1) shl uint64(scanners.len)) - 2
  var todo = @[0]
  while todo.len > 0:
    let i = todo.pop
    for j in need.bits:
      if align(scanners[i], scanners[j], 0):
        discard align(scanners[i], scanners[j], 1)
        discard align(scanners[i], scanners[j], 2)
        need.flipBit(j)
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
      let dist = (abs(a.offset[0] - b.offset[0]) +
                  abs(a.offset[1] - b.offset[1]) +
                  abs(a.offset[2] - b.offset[2]))
      result = max(result, dist)
