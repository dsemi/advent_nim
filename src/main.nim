import fusion/matching
import httpclient
import os
import sequtils
import std/monotimes
import strformat
import strutils
import sugar
import tables
import terminal
import times

import problems

const fetchIntervalMs = 5000

var lastCall: Time = getTime() - fetchIntervalMs.milliseconds
proc downloadInput(url: string, outFile: string) =
  let diff = int((getTime() - lastCall).inMilliseconds)
  if diff < fetchIntervalMs:
    sleep(fetchIntervalMs - diff)
  let cookie = getEnv("AOC_SESSION")
  var client = newHttpClient()
  client.headers = newHttpHeaders({"Cookie": cookie})
  let dir = parentDir(outFile)
  if not dirExists(dir):
    createDir(dir)
  downloadFile(client, url, outFile)
  lastCall = getTime()

proc getInput(year: int, day: int): string =
  let inputFile = fmt"inputs/{year}/input{day}.txt"
  if not fileExists(inputFile):
    echo fmt"Downloading input for Year {year} Day {day}"
    downloadInput(fmt"https://adventofcode.com/{year}/day/{day}/input", inputFile)
  readFile(inputFile).strip(leading = false)

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
  let contents = getInput(year, day)
  echo fmt"Day {day}"
  let outstr = "Part $1: $2  Elapsed time $3 seconds"
  let (ans1, t1) = timeit(probs[year][day][0], contents)
  echo outstr.format(1, align(ans1, 32), colorizeTime(t1))
  let (ans2, t2) = timeit(probs[year][day][1], contents)
  echo outstr.format(2, align(ans2, 32), colorizeTime(t2))
  t1 + t2

let year = commandLineParams()[0].parseInt
var total = 0.0
for daystr in commandLineParams()[1 .. ^1]:
  let days = if "-" in daystr:
               [@a, @b] := daystr.split("-")
               toSeq(a.parseInt .. b.parseInt)
             else:
               @[daystr.parseInt]
  for day in days:
    total += run(year, day)
echo fmt"Total: {total:53.3f} seconds"
