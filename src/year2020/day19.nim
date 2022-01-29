import algorithm
import fusion/matching
import sequtils
import strutils

type
  RuleKind = enum
    single,
    multi
  Rule = ref object
    case kind: RuleKind
    of single: ch: char
    of multi: rss: seq[seq[int]]

proc parse(input: string): (seq[Rule], seq[string]) =
  [@rules, @messages] := input.split("\n\n")
  var res: seq[(int, Rule)]
  for line in rules.splitlines:
    [@k, @v] := line.split(": ")
    let rule = if v[0] == '"':
      Rule(kind: single, ch: v[1])
    else:
      Rule(kind: multi, rss: v.split(" | ").mapIt(it.split.map(parseInt)))
    res.add((k.parseInt, rule))
  res = res.sortedByIt(it[0])
  for i, v in res:
    doAssert i == v[0]
  (res.mapIt(it[1]), messages.splitlines)

proc countMatches(rules: seq[Rule], messages: seq[string]): int =
  proc check(s: string, ss: seq[int]): bool =
    if s.len == 0 or ss.len == 0:
      return s.len == 0 and ss.len == 0
    let rule = rules[ss[0]]
    if rule.kind == single:
      return s[0] == rule.ch and check(s[1..^1], ss[1..^1])
    return rule.rss.anyIt(check(s, concat(it, ss[1..^1])))

  for message in messages:
    if check(message, @[0]):
      inc result

proc part1*(input: string): int =
  let (rules, messages) = parse(input)
  countMatches(rules, messages)

proc part2*(input: string): int =
  var (rules, messages) = parse(input)
  rules[8] = Rule(kind: multi, rss: @[@[42], @[42, 8]])
  rules[11] = Rule(kind: multi, rss: @[@[42, 31], @[42, 11, 31]])
  countMatches(rules, messages)
