import fusion/matching
import strscans
import strutils
import tables

proc parse(input: string): Table[string, seq[(int, string)]] =
  result = initTable[string, seq[(int, string)]]()
  for line in input.splitLines:
    [@outerBag, @innerBags] := line.split(" bags contain ")
    var bags = newSeq[(int, string)]()
    for bag in innerBags.split(", "):
      if bag == "no other bags.":
        continue
      var n: int
      var name1, name2: string
      doAssert bag.scanf("$i $w $w", n, name1, name2)
      bags.add((n, name1 & " " & name2))
    result[outerBag] = bags

proc part1*(input: string): int =
  let m = parse(input)
  var rev = initTable[string, seq[string]]()
  for k, v in m.pairs:
    for es in v:
      rev.mgetOrPut(es[1], newSeq[string]()).add(k)
  var stack = rev["shiny gold"]
  var visited = initTable[string, bool]()
  while stack.len > 0:
    let v = stack.pop
    if not visited.hasKeyOrPut(v, true):
      inc result
      stack.add(rev.getOrDefault(v, newSeq[string]()))

proc countBags(m: Table[string, seq[(int, string)]], k: string): int =
  for (n, k2) in m[k]:
    result += n + n * countBags(m, k2)

proc part2*(input: string): int =
  countBags(parse(input), "shiny gold")
