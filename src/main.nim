import algorithm
import fusion/matching
import options
import os
import parsetoml
import sequtils
import std/monotimes
import strformat
import strutils
import sugar
import tables
import terminal
import times
import unittest

import problems

proc colorizeTime(t: float): string =
  let s = fmt"{t:.3f}"
  if t < 0.5:
    return ansiForegroundColorCode(fgGreen) & s & ansiResetCode
  if t < 1.0:
    return ansiForegroundColorCode(fgYellow) & s & ansiResetCode
  return ansiForegroundColorCode(fgRed) & s & ansiResetCode

proc timeit(f: (string) -> string, inp: string): (string, float) =
  let startT = getMonoTime()
  var ans = f(inp)
  let endT = getMonoTime()
  let t = endT - startT
  return (ans, float(t.inMicroseconds) / 1_000_000)

proc printOutput(part: int, output: string, t: float) =
  stdout.write fmt"Part {part}: "
  let lns = output.splitLines
  let length = lns.len
  for i, ln in lns:
    if i == length - 1:
      if i == 0:
        echo "$1  Elapsed time $2 seconds".format(align(ln, 54), colorizeTime(t))
      else:
        echo "$1  Elapsed time $2 seconds".format(alignLeft(ln, 62), colorizeTime(t))
    else:
      echo ln

proc run(year: int, day: int): Option[(float, string, string)] =
  if year notin probs or day notin probs[year]:
    echo fmt"{year} Day {day} not implemented"
    return none((float, string, string))
  let contents = getInput(year, day, true)
  echo fmt"Day {day}"
  let (ans1, t1) = timeit(probs[year][day][0], contents)
  printOutput(1, ans1, t1)
  let (ans2, t2) = timeit(probs[year][day][1], contents)
  printOutput(2, ans2, t2)
  echo ""
  some((t1 + t2, ans1, ans2))

if commandLineParams()[0] == "test":
  let expectedAnswers = parseFile("tests/expectedAnswers.toml")
  var years = probs.keys.toSeq
  years.sort
  for y in years:
    suite $y:
      var days = probs[y].keys.toSeq
      days.sort
      for d in days:
        let f = probs[y][d]
        test $d:
          let input = getInput(y, d)

          var expected = expectedAnswers[$y][$d]["part1"].getStr
          var actual = f[0](input)
          check(expected == actual)

          expected = expectedAnswers[$y][$d]["part2"].getStr
          actual = f[1](input)
          check(expected == actual)
elif commandLineParams()[0] == "submit":
  let args = commandLineParams()[1 .. ^1]
  doAssert args.len == 2
  let year = args[0].parseInt
  let day = args[1].parseInt
  let res = run(year, day)
  if res.isSome:
    let (_, a1, a2) = res.get
    let (part, ans) = if a2 == "" or a2 == "0":
                        (1, a1)
                      else:
                        (2, a2)
    submitAnswer(year, day, part, ans)
else:
  let year = commandLineParams()[0].parseInt
  var total = 0.0
  var (mx, md) = (0.0, 0)
  let days = if commandLineParams()[1 .. ^1].len > 0: commandLineParams()[1 .. ^1]
             else: (1..25).toSeq.mapIt($it)
  for daystr in days:
    let days = if "-" in daystr:
                 [@a, @b] := daystr.split("-")
                 toSeq(a.parseInt .. b.parseInt)
               else:
                 @[daystr.parseInt]
    for day in days:
      let res = run(year, day)
      if res.isSome:
        let t = res.get[0]
        total += t
        if t > mx:
          mx = t
          md = day

  echo fmt"Max: Day {md:2} {mx:70.3f} seconds"
  echo fmt"Total: {total:75.3f} seconds"
