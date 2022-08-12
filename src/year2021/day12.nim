import sequtils
import strutils
import tables

type cave = ref object
  lowercase: bool
  visited: int
  start: bool
  fin: bool
  neighbors: seq[cave]

proc mkCave(name: string): cave =
  cave(lowercase: name.all(isLowerAscii),
       start: name == "start",
       fin: name == "end")

proc parse(input: string): cave =
  var caves = initTable[string, cave]()
  for line in input.splitlines:
    let v = line.split('-', 1)
    var a = caves.mgetOrPut(v[0], mkCave(v[0]))
    var b = caves.mgetOrPut(v[1], mkCave(v[1]))
    a.neighbors.add(b)
    b.neighbors.add(a)
  caves["start"]

proc dfs(c: var cave, canRevisit: bool): int =
  var canRevisit = canRevisit
  if c.fin:
    return 1
  elif c.lowercase and c.visited > 0:
    if not canRevisit or c.start:
      return 0
    canRevisit = false
  inc c.visited
  for neighb in c.neighbors.mitems:
    result += dfs(neighb, canRevisit)
  dec c.visited

proc part1*(input: string): int =
  var start = parse(input)
  dfs(start, false)

proc part2*(input: string): int =
  var start = parse(input)
  dfs(start, true)
