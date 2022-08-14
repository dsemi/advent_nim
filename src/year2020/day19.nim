import algorithm
import fusion/matching
import sequtils
import strutils
import streams

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

proc check(s: Stream, rules: openArray[Rule], r: int): bool =
  let rule = rules[r]
  if rule.kind == single:
    return s.readChar == rule.ch
  let currentPos = s.getPosition
  for rs in rule.rss:
    s.setPosition(currentPos)
    if rs.allIt(s.check(rules, it)):
      return true

proc part1*(input: string): int =
  let (rules, messages) = parse(input)
  for message in messages:
    var s = message.newStringStream
    if s.check(rules, 0) and s.atEnd:
      inc result

proc part2*(input: string): int =
  var (rules, messages) = parse(input)
  for message in messages:
    var s = message.newStringStream
    var cnt42, cnt31, pos: int
    while s.check(rules, 42):
      pos = s.getPosition
      inc cnt42
    if cnt42 > 0:
      s.setPosition(pos)
      while s.check(rules, 31):
        inc cnt31
      if s.atEnd and cnt42 > cnt31 and cnt31 > 0:
        inc result
