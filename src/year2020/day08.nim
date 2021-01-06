import intsets
import strutils
import sugar
import unpack

proc parse(input: string): seq[(string, int)] =
  result = collect(newSeq):
    for line in input.splitlines:
      [cmd, n] <- line.split()
      (cmd, n.parseInt)

proc run(prog: seq[(string, int)]): (int, bool) =
  var visited = initIntSet()
  var acc = 0
  var i = 0
  while 0 <= i and i < prog.len:
    if i in visited:
      return (acc, false)
    visited.incl(i)
    let (cmd, n) = prog[i]
    case cmd:
      of "acc":
        acc += n
      of "jmp":
        i += n - 1
      else:
        discard
    i += 1
  return (acc, true)

proc part1*(input: string): int =
  run(parse(input))[0]

proc flip(cmd: var string) =
  cmd = case cmd:
          of "jmp": "nop"
          of "nop": "jmp"
          else: cmd

proc part2*(input: string): int =
  var prog = parse(input)
  for i in 0 .. prog.high:
    flip(prog[i][0])
    let (ans, fin) = run(prog)
    flip(prog[i][0])
    if fin:
      return ans
