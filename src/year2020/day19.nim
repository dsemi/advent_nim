import sequtils
import strutils
import sugar
import tables
import unpack

var singles = initTable[int, char]()
var multi = initTable[int, seq[seq[int]]]()

proc parse(input: string): seq[string] =
  [rules, messages] <- input.split("\n\n")
  for line in rules.splitlines:
    [k, v] <- line.split(": ")
    if v[0] == '"':
      singles[k.parseInt] = v[1]
    else:
      multi[k.parseInt] = v.split(" | ").mapIt(it.split.map(parseInt))
  messages.splitlines

proc countMatches(messages: seq[string]): int =
  proc go(rule: int, s: string, i: int = 0): seq[int] =
    if i > s.high:
      return @[]
    elif rule in singles:
      return if s[i] == singles[rule]: @[i+1] else: @[]
    for rs in multi[rule]:
      var fold = @[i]
      for r in rs:
        fold = collect(newSeq):
          for x in fold:
            for y in go(r, s, x):
              y
      result.add(fold)
  for message in messages:
    if message.len in go(0, message):
      result += 1

proc part1*(input: string): int =
  countMatches(parse(input))

proc part2*(input: string): int =
  let messages = parse(input)
  multi[8] = @[@[42], @[42, 8]]
  multi[11] = @[@[42, 31], @[42, 11, 31]]
  countMatches(messages)
