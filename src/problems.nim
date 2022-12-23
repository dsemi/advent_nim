import htmlparser
import httpclient
import json
import macros
import options
import os
import strformat
import strutils
import sugar
import tables
import times
import uri
import xmltree

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
  client.downloadFile(url, outFile)
  lastCall = getTime()

proc getInput*(year: int, day: int, download: bool = false): string =
  let inputFile = fmt"inputs/{year}/input{day}.txt"
  if not fileExists(inputFile) and download:
    echo fmt"Downloading input for Year {year} Day {day}"
    downloadInput(fmt"https://adventofcode.com/{year}/day/{day}/input", inputFile)
  readFile(inputFile).strip(leading = false)

proc submitAnswer*(year, day, part: int, ans: string) =
  let url = fmt"https://adventofcode.com/{year}/day/{day}/answer"
  let data = {"level": $part, "answer": ans}
  var client = newHttpClient()
  let cookie = getEnv("AOC_SESSION")
  client.headers = newHttpHeaders({"Cookie": cookie, "content-type": "application/x-www-form-urlencoded"})
  echo fmt"{year} day {day} part {part}: {ans}"
  stdout.write "Do you want to submit? [Y/n] "
  if stdin.readLine.strip notin ["Y", "y", ""]:
    return
  let resp = client.postContent(url, data.encodeQuery)
  try:
    echo resp.parseHtml.child("html").child("body").child("main").child("article").child("p").innerText
  except CatchableError:
    echo "Error getting relevant piece of html, outputting full response"
    echo resp

proc to(x: string): string = x
proc to(x: SomeNumber): string = $x
proc to[T](x: Option[T]): string = x.get.to
proc to[T](x: (T, T)): string = x[0].to & "," & x[1].to
proc to[T](x: (T, T, T)): string = x[0].to & "," & x[1].to & "," & x[2].to

proc wrap[T](f: (string) -> T): (string) -> string =
  return proc(inp: string): string = inp.f.to

macro genProblems(s: untyped): untyped =
  result = newNimNode(nnkStmtList)
  var tbl = newNimNode(nnkTableConstr)
  for _, dir in walkDir("src"):
    if dir.rsplit('/', 1)[1].startsWith("year"):
      var year = newNimNode(nnkTableConstr)
      let y = dir[8 .. ^1].parseInt
      for _, f in walkDir(dir, relative=true):
        if f.startsWith("day"):
          let dir = dir[4 .. ^1]
          let module = fmt"{dir}/{f[0 ..< ^4]}"
          let alias = module.replace("/", "")
          let moduleI = ident(module)
          let aliasI = ident(alias)
          result.add quote do:
            import `moduleI` as `aliasI`
          let d = f[3 .. 4].parseInt
          let idP = ident(fmt"year{y}day{d:02}")
          let idP1 = ident("part1")
          let idP2 = ident("part2")
          let tup = quote do:
            (wrap(`idP`.`idP1`), wrap(`idP`.`idP2`))
          year.add(newColonExpr(newLit(d), tup))
      tbl.add(newColonExpr(newLit(y), newCall("toTable", year)))
  let pbs = ident("probs")
  result.add quote do:
    let `pbs`* = `tbl`.toTable

# No idea why this works only when a string is provided
# I think something to do with getting the context from where the macro is run
# Check dumpAstGen, dumpTree
genProblems("wat")
