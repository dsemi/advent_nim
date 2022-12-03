import fusion/matching
import sequtils
import strutils
import sugar

type
  Pipe = ref object
    a: int
    b: int
    used: bool

  Builder[T] = ref object
    a: seq[seq[Pipe]]
    b: seq[seq[Pipe]]
    f: proc(x: T, y: Pipe): T

proc parsePipes(input: string): (seq[Pipe], int) =
  for line in input.splitLines:
    [@a, @b] := line.split('/').map(parseInt)
    result[0].add(Pipe(a: a, b: b))
    result[1] = max(result[1], max(a, b))

proc build[T](b: Builder[T], port: int, curr: T): T =
  result = curr
  template run(x: untyped): untyped =
    for pipe in x[port].mitems:
      if not pipe.used:
        pipe.used = true
        result = max(result, b.build(pipe.a + pipe.b - port, b.f(curr, pipe)))
        pipe.used = false
  run(b.a)
  run(b.b)

proc solve[T](input: string, start: T, step: (T, Pipe) -> T): T =
  let (pipes, mx) = input.parsePipes
  var a = newSeqWith(mx + 1, newSeq[Pipe]())
  var b = newSeqWith(mx + 1, newSeq[Pipe]())
  for pipe in pipes:
    a[pipe.a].add(pipe)
    if pipe.a != pipe.b:
      b[pipe.b].add(pipe)
  Builder[T](a: a, b: b, f: step).build(0, start)

proc part1*(input: string): int =
  input.solve(0, (s, p) => s + p.a + p.b)

proc part2*(input: string): int =
  input.solve((0, 0), (s, p) => (s[0] + 1, s[1] + p.a + p.b))[1]
