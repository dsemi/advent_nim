import algorithm
import fusion/matching
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
  if ans == "":
    ans = "Not implemented"
  let t = endT - startT
  return (ans, float(t.inMicroseconds) / 1_000_000)

proc run(year: int, day: int): float =
  if year notin probs or day notin probs[year]:
    echo fmt"{year} Day {day} not implemented"
    return 0
  let contents = getInput(year, day, true)
  echo fmt"Day {day}"
  let outstr = "Part $1: $2  Elapsed time $3 seconds"
  let (ans1, t1) = timeit(probs[year][day][0], contents)
  echo outstr.format(1, align(ans1, 32), colorizeTime(t1))
  let (ans2, t2) = timeit(probs[year][day][1], contents)
  echo outstr.format(2, align(ans2, 32), colorizeTime(t2))
  t1 + t2

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
else:
  let year = commandLineParams()[0].parseInt
  var total = 0.0
  let days = if commandLineParams()[1 .. ^1].len > 0: commandLineParams()[1 .. ^1]
             else: (1..25).toSeq.mapIt($it)
  for daystr in days:
    let days = if "-" in daystr:
                 [@a, @b] := daystr.split("-")
                 toSeq(a.parseInt .. b.parseInt)
               else:
                 @[daystr.parseInt]
    for day in days:
      total += run(year, day)
  echo fmt"Total: {total:53.3f} seconds"
