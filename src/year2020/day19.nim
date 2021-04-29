import algorithm
import sequtils
import strutils
import sugar
import unpack

type
  RuleKind = enum
    single,
    multi
  Rule = ref object
    case kind: RuleKind
    of single: ch: char
    of multi: rss: seq[seq[int]]

proc parse(input: string): (seq[Rule], seq[string]) =
  [rules, messages] <- input.split("\n\n")
  var res: seq[(int, Rule)]
  for line in rules.splitlines:
    [k, v] <- line.split(": ")
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
  proc go(rule: Rule, s: string, i: int = 0): seq[int] =
    if i > s.high:
      return @[]
    elif rule.kind == single:
      return if s[i] == rule.ch: @[i+1] else: @[]
    for rs in rule.rss:
      var fold = @[i]
      for r in rs:
        fold = collect(newSeq):
          for x in fold:
            for y in go(rules[r], s, x):
              y
      result.add(fold)
  for message in messages:
    if message.len in go(rules[0], message):
      result += 1

proc part1*(input: string): int =
  let (rules, messages) = parse(input)
  countMatches(rules, messages)

proc part2*(input: string): int =
  var (rules, messages) = parse(input)
  rules[8] = Rule(kind: multi, rss: @[@[42], @[42, 8]])
  rules[11] = Rule(kind: multi, rss: @[@[42, 31], @[42, 11, 31]])
  countMatches(rules, messages)
