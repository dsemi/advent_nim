import sequtils
import streams
import strutils

type
  Kind = enum
    Reg, Pair
  Snailfish = ref object
    case kind: Kind
    of Reg: v: int
    of Pair: l, r: Snailfish

proc parse(line: StringStream): Snailfish =
  if line.peekChar == '[':
    discard line.readChar
    let left = line.parse
    discard line.readChar
    let right = line.parse
    discard line.readChar
    Snailfish(kind: Pair, l: left, r: right)
  else:
    var n = 0
    while line.peekChar in '0'..'9':
      n = n * 10 + line.readChar.ord - '0'.ord
    Snailfish(kind: Reg, v: n)

proc exp(fish: var Snailfish, prev: var ptr int, next: var int, depth: int): bool =
  case fish.kind
  of Reg:
    if next != -1:
      fish.v += next
      return true
    prev = addr fish.v
  of Pair:
    if next == -1 and depth == 4:
      if prev != nil:
        prev[] += fish.l.v
        prev = nil
      next = fish.r.v
      fish = Snailfish(kind: Reg, v: 0)
    else:
      return exp(fish.l, prev, next, depth + 1) or exp(fish.r, prev, next, depth + 1)

proc explode(fish: var Snailfish): bool =
  var prev: ptr int
  var next = -1
  exp(fish, prev, next, 0) or next != -1

proc split(fish: var Snailfish): bool =
  case fish.kind
  of Reg:
    if fish.v > 9:
      fish = Snailfish(kind: Pair,
                       l: Snailfish(kind: Reg, v: fish.v div 2),
                       r: Snailfish(kind: Reg, v: (fish.v + 1) div 2))
      return true
  of Pair:
    return split(fish.l) or split(fish.r)

proc mag(fish: Snailfish): int =
  case fish.kind
  of Reg: fish.v
  of Pair: 3 * mag(fish.l) + 2 * mag(fish.r)

proc add(a, b: Snailfish): Snailfish =
  result = Snailfish(kind: Pair, l: a, r: b)
  while result.explode or result.split:
    discard

proc part1*(input: string): int =
  input.splitlines.mapIt(it.newStringStream.parse).foldl(add(a, b)).mag

proc part2*(input: string): int =
  let ns = input.splitlines.mapIt(it.newStringStream.parse)
  for a in ns:
    for b in ns:
      var c, d: Snailfish
      deepCopy(c, a)
      deepCopy(d, b)
      result = max(result, add(c, d).mag)
