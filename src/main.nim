import os
import sequtils
import strformat
import strutils
import sugar
import tables
import terminal
import times
import unpack

import problems

proc colorizeTime(t: float): string =
  let s = fmt"{t:.3f}"
  if t < 0.5:
    return ansiForegroundColorCode(fgGreen) & s & ansiResetCode
  if t < 1.0:
    return ansiForegroundColorCode(fgYellow) & s & ansiResetCode
  return ansiForegroundColorCode(fgRed) & s & ansiResetCode

proc timeit(f: (string) -> string, inp: string): (string, float) =
  let startT = getTime()
  var ans = f(inp)
  let endT = getTime()
  if ans == "":
    ans = "Not implemented"
  let t = endT - startT
  return (ans, float(t.inMicroseconds) / 1_000_000)

proc run(year: int, day: int): float =
  let contents = readFile(fmt"inputs/{year}/input{day}.txt").strip
  echo fmt"Day {day}"
  let outstr = "Part $1: $2  Elapsed time $3 seconds"
  if year notin probs or day notin probs[year]:
    echo "Not implemented"
    return 0
  let (ans1, t1) = timeit(probs[year][day][0], contents)
  echo outstr.format(1, align(ans1, 32), colorizeTime(t1))
  let (ans2, t2) = timeit(probs[year][day][1], contents)
  echo outstr.format(2, align(ans2, 32), colorizeTime(t2))
  t1 + t2

let year = commandLineParams()[0].parseInt
var total = 0.0
for daystr in commandLineParams()[1 .. ^1]:
  let days = if "-" in daystr:
               [a, b] <- daystr.split("-")
               toSeq(a.parseInt .. b.parseInt)
             else:
               @[daystr.parseInt]
  for day in days:
    total += run(year, day)
echo fmt"Total: {total:53.3f} seconds"
