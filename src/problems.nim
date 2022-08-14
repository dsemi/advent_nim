import httpclient
import macros
import options
import os
import strformat
import strutils
import sugar
import tables
import times

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

proc getInput*(year: int, day: int, download: bool = false): string =
  let inputFile = fmt"inputs/{year}/input{day}.txt"
  if not fileExists(inputFile) and download:
    echo fmt"Downloading input for Year {year} Day {day}"
    downloadInput(fmt"https://adventofcode.com/{year}/day/{day}/input", inputFile)
  readFile(inputFile).strip(leading = false)

# Use SomeNumber
# Could implement a `to` function for each type
# Then add concept for something that has a `to` and recv that in wrap
# Would allow for tuples of any valid type

proc wrap(f: (string) -> string): (string) -> string = f

proc wrap(f: (string) -> int): (string) -> string =
  return proc(inp: string): string = $f(inp)

proc wrap(f: (string) -> int64): (string) -> string =
  return proc(inp: string): string = $f(inp)

proc wrap(f: (string) -> uint16): (string) -> string =
  return proc(inp: string): string = $f(inp)

proc wrap(f: (string) -> uint64): (string) -> string =
  return proc(inp: string): string = $f(inp)

proc wrap(f: (string) -> Option[int]): (string) -> string =
  return proc(inp: string): string = $f(inp).get

proc wrap(f: (string) -> (int, int)): (string) -> string =
  return proc(inp: string): string =
    let (a, b) = f(inp)
    $a & "," & $b

proc wrap(f: (string) -> (int, int, int)): (string) -> string =
  return proc(inp: string): string =
    let (a, b, c) = f(inp)
    $a & "," & $b & "," & $c

macro genProblems(s: untyped): untyped =
  result = newNimNode(nnkStmtList)
  var tbl = newNimNode(nnkTableConstr)
  for _, dir in walkDir("src"):
    if dir.rsplit('/', 1)[1].startswith("year"):
      var year = newNimNode(nnkTableConstr)
      let y = dir[8 .. ^1].parseInt
      for _, f in walkDir(dir, relative=true):
        if f.startswith("day"):
          let dir = dir[4 .. ^1]
          let module = fmt"{dir}/{f[0 ..< ^4]}"
          let alias = module.replace("/", "")
          result.add(newNimNode(nnkImportStmt).add(infix(ident(module), "as", ident(alias))))
          let d = f[3 .. 4].parseInt
          let tup = newNimNode(nnkTupleConstr).add(
            newCall("wrap", newDotExpr(ident(fmt"year{y}day{d:02}"), ident("part1"))),
            newCall("wrap", newDotExpr(ident(fmt"year{y}day{d:02}"), ident("part2"))))
          year.add(newColonExpr(newLit(d), tup))
      tbl.add(newColonExpr(newLit(y), newCall("toTable", year)))
  result.add(newLetStmt(postfix(ident("probs"), "*"), newCall("toTable", tbl)))

# No idea why this works only when a string is provided
# I think something to do with getting the context from where the macro is run
# Check dumpAstGen, dumpTree
genProblems("wat")
