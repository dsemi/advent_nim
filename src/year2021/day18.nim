import sequtils
import streams
import strutils

type
  Num = tuple
    depth: int
    value: int
  Fish = seq[Num]

proc parse(line: StringStream, depth: int = 0): Fish =
  if line.peekChar == '[':
    discard line.readChar
    result.add(line.parse(depth + 1))
    discard line.readChar
    result.add(line.parse(depth + 1))
    discard line.readChar
  else:
    var n = 0
    while line.peekChar in '0'..'9':
      n = n * 10 + line.readChar.ord - '0'.ord
    result.add(@[(depth, n)])

proc explode(fish: var Fish): bool =
  for i, f in fish.mpairs:
    if f.depth > 4:
      if i > 0:
        fish[i-1].value += f.value
      if i + 2 < fish.len:
        fish[i+2].value += fish[i+1].value
      fish.delete(i+1)
      f.value = 0
      f.depth -= 1
      return true

proc split(fish: var Fish): bool =
  for i, f in fish.mpairs:
    if f.value > 9:
      let (depth, val) = f
      f.value = val div 2
      f.depth = depth + 1
      fish.insert((depth+1, (val + 1) div 2), i+1)
      return true

proc plus(a, b: Fish): Fish =
  result.add(a)
  result.add(b)
  for v in result.mitems:
    v.depth += 1
  while result.explode or result.split:
    discard

proc mag(a: var Fish): int =
  while a.len > 1:
    for i in a.low .. a.high - 1:
      if a[i].depth == a[i+1].depth:
        a[i] = (a[i].depth-1, 3*a[i].value + 2*a[i+1].value)
        a.delete(i+1)
        break
  a[0].value

proc part1*(input: string): int =
  input.splitlines.mapIt(it.newStringStream.parse).foldl(plus(a, b)).mag

proc part2*(input: string): int =
  let ns = input.splitlines.mapIt(it.newStringStream.parse)
  for a in ns:
    for b in ns:
      var x = plus(a, b)
      result = max(result, x.mag)
