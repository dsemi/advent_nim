import math
import sequtils
import strutils
import sugar

import "../utils"

type Ingredient = tuple
  capacity: int
  durability: int
  flavor: int
  texture: int
  calories: int

proc `*`(n: int, a: Ingredient): Ingredient =
  (n * a.capacity,
   n * a.durability,
   n * a.flavor,
   n * a.texture,
   n * a.calories)

proc `+=`(a: var Ingredient, b: Ingredient) =
  a.capacity += b.capacity
  a.durability += b.durability
  a.flavor += b.flavor
  a.texture += b.texture
  a.calories += b.calories

proc parse(input: string): seq[Ingredient] =
  for line in input.splitlines:
    let ings = line.split(": ")[^1]
    let ns = ings.split(", ").mapIt(it.split[^1].parseInt)
    result.add((ns[0], ns[1], ns[2], ns[3], ns[4]))

proc scores(total: int, calFilter: (int) -> bool, input: string): int =
  let ings = parse(input)
  var res = 0
  proc f(ms: seq[int]) =
    var tot: Ingredient = (0, 0, 0, 0, 0)
    for (n, i) in ms.zip(ings):
      tot += n * i
    if calFilter(tot.calories):
      res = max(res, [tot.capacity, tot.durability, tot.flavor, tot.texture].mapIt(max(0, it)).prod)
  partitions(ings.len, total, f)
  res

proc part1*(input: string): int =
  scores(100, (_) => true, input)

proc part2*(input: string): int =
  scores(100, (x) => x == 500, input)
