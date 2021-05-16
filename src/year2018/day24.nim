import algorithm
import fusion/matching
import intsets
import options
import pegs
import sequtils
import strutils
import tables

type Group = ref object
  name: string
  numUnits: int
  hitPts: int
  dmg: int
  element: string
  initiative: int
  weaknesses: seq[string]
  immunities: seq[string]

let grammar = peg"""grammar <- init {('(' modifiers ')')?} tail
                    init <- {\d+} ' units each with ' {\d+} ' hit points '
                    tail <- \s* 'with an attack that does ' {\d+} ' ' {\w+} ' damage at initiative ' {\d+}
                    elems <- \w+ (', ' elems)*
                    modifiers <- ('weak' / 'immune') ' to ' elems ('; ' modifiers)*"""

proc parseGroups(input: string): Table[int, Group] =
  var i = 0
  for army in input.split("\n\n"):
    [@n, all @rest] := army.splitLines
    for line in rest:
      var caps: array[6, string]
      doAssert match(line, grammar, caps)
      [@u, @hp, @d, @i] := (caps[0..1] & caps[3..3] & caps[5..5]).map(parseInt)
      let e = caps[4]
      var group = Group(name: n[0..^2], numUnits: u, hitPts: hp, dmg: d, element: e, initiative: i)
      if caps[2] != "":
        for modifier in caps[2][1..^2].split("; "):
          [@mn, @ms] := modifier.split(" to ")
          case mn:
            of "weak": group.weaknesses = ms.split(", ")
            of "immune": group.immunities = ms.split(", ")
            else: raiseAssert "Bad modifier: " & ms
      result[i] = group
      inc i

proc effPwr(group: Group): int =
  group.numUnits * group.dmg

proc calcDmg(a, b: Group): int =
  if a.element in b.weaknesses: 2 * a.effPwr
  elif a.element in b.immunities: 0
  else: a.effPwr

proc selectTarget(groups: Table[int, Group], attacked: IntSet, grp: Group): Option[int] =
  var mx = (0, 0, 0, 0)
  for (i, g) in groups.pairs:
    if grp.name != g.name and i notin attacked:
      let mx2 = (i, grp.calcDmg(g), g.effPwr, g.initiative)
      if (mx2[1], mx2[2], mx2[3]) > (mx[1], mx[2], mx[3]):
        mx = mx2
  if mx[1] > 0:
    return some(mx[0])

proc targetSelection(groups: Table[int, Group]): seq[(int, int)] =
  let targets = toSeq(groups.pairs).sortedByIt((-it[1].effPwr, -it[1].initiative))
  var s: IntSet
  for (i, g) in targets:
    if Some(@t) ?= groups.selectTarget(s, g):
      s.incl(t)
      result.add((i, t))
  result = result.sortedByIt(-groups[it[0]].initiative)

proc attack(groups: var Table[int, Group], atks: seq[(int, int)]): bool =
  for (k1, k2) in atks:
    if k1 in groups:
      let g1 = groups[k1]
      let g2 = groups[k2]
      let unitsLeft = g2.numUnits - g1.calcDmg(g2) div g2.hitPts
      if unitsLeft != groups[k2].numUnits:
        result = true
      if unitsLeft <= 0:
        groups.del(k2)
      else:
        groups[k2].numUnits = unitsLeft

proc battle(groups: var Table[int, Group]): bool =
  var changed = true
  while changed:
    block checkEnd:
      var name: string
      for group in groups.values:
        name = group.name
        break
      for group in groups.values:
        if name != group.name:
          break checkEnd
      return true
    let atks = groups.targetSelection
    changed = groups.attack(atks)

proc part1*(input: string): int =
  var groups = input.parseGroups
  discard groups.battle
  for g in groups.values:
    result += g.numUnits

proc part2*(input: string): int =
  for n in 0..int.high:
    result = 0
    var groups = input.parseGroups
    for g in groups.mvalues:
      if g.name == "Immune System":
        g.dmg += n
    if groups.battle:
      for g in groups.values:
        if g.name == "Immune System":
          result += g.numUnits
      if result > 0:
        break
