import algorithm
import sequtils
import sets
import strutils
import sugar
import tables
import unpack

proc parse(input: string): seq[(seq[string], seq[string])] =
  result = collect(newSeq):
    for line in input.splitlines:
      [ings, alls] <- line.split(" (contains ")
      (ings.split(), alls[0..^2].split(", "))

proc allergens(foods: seq[(seq[string], seq[string])]): Table[string, HashSet[string]] =
  result = initTable[string, HashSet[string]]()
  for (ings, alls) in foods:
    let ingset = toHashSet(ings)
    for allergen in alls:
      result[allergen] = result.getOrDefault(allergen, ingset) * ingset

proc part1*(input: string): int =
  let foods = parse(input)
  let alls = allergens(foods)
  let ingredients = collect(newSeq):
    for (ings, _) in foods:
      for x in ings:
        x
  var safe = tohashSet(ingredients)
  for v in alls.values:
    safe = safe - v
  for i in ingredients:
    if i in safe:
      result += 1

proc part2*(input: string): string =
  var alls = allergens(parse(input))
  var done = initTable[string, string]()
  while alls.len != 0:
    for (k, v) in alls.mpairs:
      if v.len == 1:
        done[k] = v.pop()
    let s = toHashSet(toSeq(done.values()))
    alls = collect(initTable):
      for (k, v) in alls.pairs:
        if not (k in done):
          {k: v-s}
  sorted(toSeq(done.pairs())).mapIt(it[1]).join(",")
