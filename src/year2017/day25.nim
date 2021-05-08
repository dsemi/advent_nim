import deques
import nre
import strutils
import unpack

type Dir = enum
  Left, Right

proc parseMachine(input: string): (int, int, seq[seq[(int, Dir, int)]]) =
  [strt, *ruleDescs] <- input.split("\n\n")
  let cap = match(strt, re"Begin in state (.)\.\nPerform a diagnostic checksum after (\d+) steps\.").get.captures
  let start = cap[0][0].ord - 'A'.ord
  let steps = cap[1].parseInt
  let ruleReg = [
    r"  If the current value is (\d+):",
    r"    - Write the value (\d+)\.",
    r"    - Move one slot to the (left|right)\.",
    r"    - Continue with state (.)\.",
  ].join("\n").re
  var rules: seq[seq[(int, Dir, int)]]
  for ruleDesc in ruleDescs:
    let state0 = match(ruleDesc, re"In state (.):").get.captures[0][0]
    rules.add(@[])
    doAssert state0.ord - 'A'.ord == rules.high
    for m in findIter(ruleDesc, ruleReg):
      [val0, val1, d, state1] <- m.captures
      rules[^1].add((val1.parseInt, if d == "left": Left else: Right, state1[0].ord - 'A'.ord))
      doAssert val0.parseInt == rules[^1].high
  (start, steps, rules)

proc part1*(input: string): int =
  let (state, steps, rules) = input.parseMachine
  var i = 0
  var tape = [0].toDeque
  var curr = state
  for _ in 1..steps:
    let (val, d, curr2) = rules[curr][tape[i]]
    curr = curr2
    tape[i] = val
    case d:
      of Left:
        if i == 0:
          tape.addFirst(0)
        else:
          dec i
      of Right:
        inc i
        if i >= tape.len:
          tape.addLast(0)
  for v in tape:
    result += v

proc part2*(input: string): string =
  " "
