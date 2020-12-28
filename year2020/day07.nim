import re
import sequtils
import strutils
import sugar
import tables

proc parse(input: string): Table[string, seq[(int, string)]] =
  result = initTable[string, seq[(int, string)]]()
  for line in input.splitlines:
    let bgs = findAll(line, re("(\\d+ )?\\w+ \\w+ bags?"))
    var vs = collect(newSeq):
      for x in bgs[1 .. ^1]:
        if "no other" notin x:
          let x = x.rsplit(' ', 1)[0]
          let parts = x.split(' ', 1)
          (parts[0].parseInt, parts[1])
    result[bgs[0].rsplit(' ', 1)[0]] = vs

proc holdsShinyGold(m: Table[string, seq[(int, string)]], k: string): bool =
  m[k].anyIt(it[1] == "shiny gold" or holdsShinyGold(m, it[1]))

proc part1*(input: string): int =
  let m = parse(input)
  for k in m.keys:
    if holdsShinyGold(m, k):
      result += 1

proc countBags(m: Table[string, seq[(int, string)]], k: string): int =
  for (n, k2) in m[k]:
    result += n + n * countBags(m, k2)

proc part2*(input: string): int =
  countBags(parse(input), "shiny gold")
