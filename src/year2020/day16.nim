import bitops
import fusion/matching
import sequtils
import std/enumerate
import strscans
import strutils
import tables

type Rule = object
  name: string
  id: uint64
  alo, ahi, blo, bhi: uint64

proc parse(input: string): (seq[Rule], seq[uint64], seq[seq[uint64]]) =
  [@rules, @yours, @others] := input.split("\n\n")
  var rls = newSeq[Rule]()
  for i, line in enumerate(rules.splitLines):
    var name: string
    var alo, ahi, blo, bhi: int
    doAssert line.scanf("$+: $i-$i or $i-$i", name, alo, ahi, blo, bhi)
    var rule = Rule(name: name, id: 1'u64 shl i,
                    alo: alo.uint64, ahi: ahi.uint64, blo: blo.uint64, bhi: bhi.uint64)
    rls.add(rule)
  let yrs = yours.splitlines()[^1].split(',').mapIt(it.parseInt.uint64)
  let othrs = others.splitlines()[1 .. ^1].mapIt(it.split(',').mapIt(it.parseInt.uint64))
  (rls, yrs, othrs)

iterator invalidValues(rules: seq[Rule], ticket: seq[uint64]): uint64 =
  for field in ticket:
    if not rules.anyIt(field in it.alo .. it.ahi or field in it.blo .. it.bhi):
      yield field

proc part1*(input: string): uint64 =
  let (rules, _, tix) = parse(input)
  for t in tix:
    for x in invalidValues(rules, t):
      result += x

proc part2*(input: string): uint64 =
  let (rules, yours, tickets) = parse(input)
  var ruleMap = initTable[uint64, Rule]()
  for rule in rules:
    ruleMap[rule.id] = rule
  let tix = tickets.filterIt(toSeq(invalidValues(rules, it)).len == 0)
  var poss = repeat(rules, yours.len)
  for t in tix:
    for i, field in t:
      var validRules: seq[Rule]
      for rule in poss[i]:
        if field in rule.alo .. rule.ahi or field in rule.blo .. rule.bhi:
          validRules.add(rule)
      poss[i] = validRules
  var possSet = newSeq[uint64](poss.len)
  for i, p in poss:
    var key: uint64
    for x in p:
      key = key or x.id
    possSet[i] = key
  while true:
    var ones: uint64
    for p in possSet:
      if p.popcount == 1:
        ones = ones or p
    if possSet.len == ones.popcount:
      break
    for i, p in possSet:
      if p.popcount > 1:
        possSet[i] = possSet[i] and not ones
  result = 1
  for i, k in possSet:
    if ruleMap[k].name.startsWith("departure"):
      result *= yours[i]
