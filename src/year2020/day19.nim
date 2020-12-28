import sequtils
import strutils
import sugar
import tables
import unpack

type
  Rule = ref object of RootObj

  Leaf = ref object of Rule
    val: char

  Node = ref object of Rule
    children: seq[seq[int]]

proc parse(input: string): (Table[int, Rule], seq[string]) =
  [rules, messages] <- input.split("\n\n")
  var ruleTbl = initTable[int, Rule]()
  for line in rules.splitlines:
    [k, v] <- line.split(": ")
    ruleTbl[k.parseInt] = if v[0] == '"':
                            Leaf(val: v[1])
                          else:
                            Node(children: v.split(" | ").mapIt(it.split.map(parseInt)))
  (ruleTbl, messages.splitlines)

proc countMatches(rules: Table[int, Rule], messages: seq[string]): int =
  proc go(rule: Rule, s: string): seq[string] =
    if s == "":
      result = @[]
    elif rule of Leaf:
      if s[0] == cast[Leaf](rule).val:
        result = @[s[1 .. ^1]]
    else:
      for rs in cast[Node](rule).children:
        var fold = @[s]
        for r in rs:
          fold = collect(newSeq):
            for x in fold:
              for y in go(rules[r], x):
                y
        result.add(fold)
  for message in messages:
    if go(rules[0], message).anyIt(it == ""):
      result += 1

proc part1*(input: string): int =
  let (rules, messages) = parse(input)
  countMatches(rules, messages)

proc part2*(input: string): int =
  var (rules, messages) = parse(input)
  rules[8] = Node(children: @[@[42], @[42, 8]])
  rules[11] = Node(children: @[@[42, 31], @[42, 11, 31]])
  countMatches(rules, messages)
