import sequtils
import strutils
import tables
import unpack

proc spin(n: int): proc(v: var string) =
  return proc(v: var string) =
    let i = v.len - n
    v = v[i..^1] & v[0..<i]

proc exchange(i, j: int): proc(v: var string) =
  return proc(v: var string) =
    (v[j], v[i]) = (v[i], v[j])

proc partner(a, b: char): proc(v: var string) =
  return proc(v: var string) =
    exchange(v.find(a), v.find(b))(v)

proc parseMoves(moves: seq[string]): seq[proc(v: var string)] =
  for move in moves:
    case move[0]
    of 's': result.add(spin(move[1..^1].parseInt))
    of 'x':
      [a, b] <- move[1..^1].split('/').map(parseInt)
      result.add(exchange(a, b))
    of 'p':
      [a, b] <- move[1..^1].split('/').mapIt(it[0])
      result.add(partner(a, b))
    else: raiseAssert "Invalid move: " & move

proc dance(n: int, moves: seq[proc(v: var string)]): string =
  result = "abcdefghijklmnop"
  var tbl: Table[string, int]
  for c in 0..<n:
    if result in tbl:
      let cycleLen = c - tbl[result]
      for _ in 1..((n - c) mod cycleLen):
        for move in moves:
          move(result)
      break
    tbl[result] = c
    for move in moves:
      move(result)

proc part1*(input: string): string =
  dance(1, input.split(',').parseMoves)

proc part2*(input: string): string =
  dance(1_000_000_000, input.split(',').parseMoves)
