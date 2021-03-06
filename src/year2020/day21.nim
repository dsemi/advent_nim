import algorithm
import fusion/matching
import sequtils
import sets
import strtabs
import strutils
import sugar
import tables

proc parse(input: string): seq[(seq[string], seq[string])] =
  collect(newSeq):
    for line in input.splitlines:
      [@ings, @alls] := line.split(" (contains ")
      (ings.split(), alls[0..^2].split(", "))

proc allergens(foods: seq[(seq[string], seq[string])]): Table[string, HashSet[string]] =
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
    result += int(i in safe)

proc part2*(input: string): string =
  var alls = allergens(parse(input))
  var done = newStringTable()
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
