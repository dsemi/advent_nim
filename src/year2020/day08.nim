import sets
import strutils
import sugar

proc parse(input: string): seq[(string, int)] =
  result = collect(newSeq):
    for line in input.splitlines:
      let w = line.split()
      (w[0], w[1].parseInt)

proc run(prog: seq[(string, int)]): (int, bool) =
  var visited = initHashSet[int]()
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

proc part2*(input: string): int =
  let progtmpl = parse(input)
  for i in 0 .. progtmpl.high:
    var prog = progtmpl
    if prog[i][0] == "jmp":
      prog[i][0] = "nop"
    elif prog[i][0] == "nop":
      prog[i][0] = "jmp"
    let (ans, fin) = run(prog)
    if fin:
      return ans
