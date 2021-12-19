import macros
import os
import strformat
import strutils
import sugar
import tables

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
# Check dumpAstGen
genProblems("wat")
