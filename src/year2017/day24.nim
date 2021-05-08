import options
import sequtils
import strutils
import sugar
import unpack

type
  Pipe = object
    a: int
    b: int
    used: bool
  Bridge = tuple
    pins: int
    pipes: seq[Pipe]

proc parsePipes(input: string): seq[Pipe] =
  for line in input.splitLines:
    [a, b] <- line.split('/').map(parseInt)
    result.add(Pipe(a: a, b: b))

proc solve[T](input: string, start: T, step: (T, Pipe) -> T): T =
  var pipes = input.parsePipes
  var start = start
  proc dfs(pins: int, v: T) =
    start = max(start, v)
    for pipe in pipes.mitems:
      if not pipe.used and (pipe.a == pins or pipe.b == pins):
        pipe.used = true
        dfs(if pipe.a == pins: pipe.b else: pipe.a, step(v, pipe))
        pipe.used = false
  dfs(0, start)
  start

proc part1*(input: string): int =
  input.solve(0, (s, p) => s + p.a + p.b)

proc part2*(input: string): int =
  input.solve((0, 0), (s, p) => (s[0] + 1, s[1] + p.a + p.b))[1]
