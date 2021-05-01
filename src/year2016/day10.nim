import algorithm
import re
import strutils
import tables

let
  valreg = re"value (\d+) goes to (\w+ \d+)"
  botreg = re"(\w+ \d+) gives low to (\w+ \d+) and high to (\w+ \d+)"

type Bot = ref object
  lo: string
  hi: string
  vals: seq[int]

proc recv(bot: var Bot, t: var Table[string, Bot], n: int) =
  bot.vals.add(n)
  if bot.vals.len == 2:
    if t.hasKeyOrPut(bot.lo, Bot(vals: @[bot.vals.min])):
      t[bot.lo].recv(t, bot.vals.min)
    if t.hasKeyOrPut(bot.hi, Bot(vals: @[bot.vals.max])):
      t[bot.hi].recv(t, bot.vals.max)

proc runFactory(input: string): Table[string, Bot] =
  var valInstrs: seq[string]
  for line in input.splitlines:
    var cap: array[3, string]
    if match(line, botreg, cap):
      result[cap[0]] = Bot(lo: cap[1], hi: cap[2])
    else:
      valInstrs.add(line)
  for instr in valInstrs:
    var cap: array[2, string]
    doAssert match(instr, valreg, cap)
    result[cap[1]].recv(result, cap[0].parseInt)

proc part1*(input: string): string =
  let tbl = runFactory(input)
  for (k, bot) in tbl.pairs:
    if bot.vals.sorted == @[17, 61]:
      return k.splitWhitespace[1]

proc part2*(input: string): int =
  let tbl = runFactory(input)
  tbl["output 0"].vals[0] *
  tbl["output 1"].vals[0] *
  tbl["output 2"].vals[0]
