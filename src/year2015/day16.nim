import fusion/matching
import strutils
import tables

var tape = {
  "children": proc (x: int): bool = x == 3,
  "cats": proc (x: int): bool = x == 7,
  "samoyeds": proc (x: int): bool = x == 2,
  "pomeranians": proc (x: int): bool = x == 3,
  "akitas": proc (x: int): bool = x == 0,
  "vizslas": proc (x: int): bool = x == 0,
  "goldfish": proc (x: int): bool = x == 5,
  "trees": proc (x: int): bool = x == 3,
  "cars": proc (x: int): bool = x == 2,
  "perfumes": proc (x: int): bool = x == 1,
}.toTable

proc findAunt(input: string): int =
  for i, line in pairs(input.splitlines):
    block aunt:
      for petstr in line.split(": ", maxsplit = 1)[^1].split(", "):
        [@pet, @cnt] := petstr.split(": ")
        if not tape[pet](cnt.parseInt):
          break aunt
      return i + 1

proc part1*(input: string): int =
  findAunt(input)

proc part2*(input: string): int =
  tape["cats"] = proc(x: int): bool = x > 7
  tape["pomeranians"] = proc(x: int): bool = x < 3
  tape["goldfish"] = proc(x: int): bool = x < 5
  tape["trees"] = proc(x: int): bool = x > 3
  findAunt(input)
