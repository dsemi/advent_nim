import fusion/matching
import sequtils
import sets
import strscans
import strutils
import sugar

type Rule = (string, seq[(int, int)])

proc parse(input: string): (seq[Rule], seq[int], seq[seq[int]]) =
  [@rules, @yours, @others] := input.split("\n\n")
  var rls = newSeq[Rule]()
  for line in rules.splitlines:
    var name: string
    var a, b, c, d: int
    doAssert line.scanf("$+: $i-$i or $i-$i", name, a, b, c, d)
    rls.add((name, @[(a, b), (c, d)]))
  let yrs = yours.splitlines()[^1].split(',').map(parseInt)
  let othrs = others.splitlines()[1 .. ^1].mapIt(it.split(',').map(parseInt))
  (rls, yrs, othrs)

proc inRange(n: int, bds: (int, int)): bool =
  let (a, b) = bds
  a <= n and n <= b

iterator invalidValues(rules: seq[Rule], ticket: seq[int]): int =
  for field in ticket:
    if not rules.anyIt(it[1].anyIt(inRange(field, it))):
      yield field

proc part1*(input: string): int =
  let (rules, _, tix) = parse(input)
  for t in tix:
    for x in invalidValues(rules, t):
      result += x

proc part2*(input: string): int =
  let (rules, yours, tickets) = parse(input)
  let tix = tickets.filterIt(toSeq(invalidValues(rules, it)).len == 0)
  var poss = repeat(rules, yours.len)
  for t in tix:
    poss = poss.zip(t).map((pf) => pf[0].filter((rule) => rule[1].any((bds) => inRange(pf[1], bds))))
  var poss2 = poss.mapIt(toHashSet(it.map((x) => x[0])))
  var ones: HashSet[string]
  while not poss2.allIt(it.len == 1):
    ones = collect(initHashSet):
      for p in poss2:
        if p.len == 1:
          for x in p:
            {x}
    poss2 = collect(newSeq):
      for p in poss2:
        if p.len > 1: p - ones else: p
  let poss3 = collect(newSeq):
    for p in poss2.mitems:
      p.pop()
  result = 1
  for (n, f) in poss3.zip(yours):
    if n.startswith("departure"):
      result *= f
