import macros
import os
import strformat
import strutils
import sugar
import tables

macro imports(s: static[string]): untyped =
  result = newStmtList()
  for _, d in walkDir("src"):
    if d.rsplit('/', 1)[1].startswith("year"):
      for _, f in walkDir(d, relative=true):
        if f.startswith("day"):
          let d = d[4 .. ^1]
          let module = fmt"{d}/{f[0 ..< ^4]}"
          let alias = module.replace("/", "")
          result.add(newNimNode(nnkImportStmt).add(infix(newIdentNode(module), "as", newIdentNode(alias))))

# No idea why this works only when a string is provided
imports("wat")

proc wrap(f: (string) -> string): (string) -> string = f

proc wrap(f: (string) -> int): (string) -> string =
  proc inner(inp: string): string = $f(inp)
  result = inner

proc wrap(f: (string) -> int64): (string) -> string =
  proc inner(inp: string): string = $f(inp)
  result = inner

proc wrap(f: (string) -> uint16): (string) -> string =
  proc inner(inp: string): string = $f(inp)
  result = inner

proc wrap(f: (string) -> (int, int)): (string) -> string =
  proc inner(inp: string): string =
    let (a, b) = f(inp)
    $a & "," & $b
  result = inner

proc wrap(f: (string) -> (int, int, int)): (string) -> string =
  proc inner(inp: string): string =
    let (a, b, c) = f(inp)
    $a & "," & $b & "," & $c
  result = inner

# Better way to generate this?
let probs* = {
  2015: {
    1: (wrap(year2015day01.part1), wrap(year2015day01.part2)),
    2: (wrap(year2015day02.part1), wrap(year2015day02.part2)),
    3: (wrap(year2015day03.part1), wrap(year2015day03.part2)),
    4: (wrap(year2015day04.part1), wrap(year2015day04.part2)),
    5: (wrap(year2015day05.part1), wrap(year2015day05.part2)),
    6: (wrap(year2015day06.part1), wrap(year2015day06.part2)),
    7: (wrap(year2015day07.part1), wrap(year2015day07.part2)),
    8: (wrap(year2015day08.part1), wrap(year2015day08.part2)),
    9: (wrap(year2015day09.part1), wrap(year2015day09.part2)),
    10: (wrap(year2015day10.part1), wrap(year2015day10.part2)),
    11: (wrap(year2015day11.part1), wrap(year2015day11.part2)),
    12: (wrap(year2015day12.part1), wrap(year2015day12.part2)),
    13: (wrap(year2015day13.part1), wrap(year2015day13.part2)),
    14: (wrap(year2015day14.part1), wrap(year2015day14.part2)),
    15: (wrap(year2015day15.part1), wrap(year2015day15.part2)),
    16: (wrap(year2015day16.part1), wrap(year2015day16.part2)),
    17: (wrap(year2015day17.part1), wrap(year2015day17.part2)),
    18: (wrap(year2015day18.part1), wrap(year2015day18.part2)),
    19: (wrap(year2015day19.part1), wrap(year2015day19.part2)),
    20: (wrap(year2015day20.part1), wrap(year2015day20.part2)),
    # 21: (wrap(year2015day21.part1), wrap(year2015day21.part2)),
    # 22: (wrap(year2015day22.part1), wrap(year2015day22.part2)),
    23: (wrap(year2015day23.part1), wrap(year2015day23.part2)),
    24: (wrap(year2015day24.part1), wrap(year2015day24.part2)),
    25: (wrap(year2015day25.part1), wrap(year2015day25.part2)),
  }.toTable,
  2016: {
    1: (wrap(year2016day01.part1), wrap(year2016day01.part2)),
    # 2: (wrap(year2016day02.part1), wrap(year2016day02.part2)),
    # 3: (wrap(year2016day03.part1), wrap(year2016day03.part2)),
    # 4: (wrap(year2016day04.part1), wrap(year2016day04.part2)),
    # 5: (wrap(year2016day05.part1), wrap(year2016day05.part2)),
    # 6: (wrap(year2016day06.part1), wrap(year2016day06.part2)),
    # 7: (wrap(year2016day07.part1), wrap(year2016day07.part2)),
    # 8: (wrap(year2016day08.part1), wrap(year2016day08.part2)),
    # 9: (wrap(year2016day09.part1), wrap(year2016day09.part2)),
    # 10: (wrap(year2016day10.part1), wrap(year2016day10.part2)),
    # 11: (wrap(year2016day11.part1), wrap(year2016day11.part2)),
    # 12: (wrap(year2016day12.part1), wrap(year2016day12.part2)),
    # 13: (wrap(year2016day13.part1), wrap(year2016day13.part2)),
    # 14: (wrap(year2016day14.part1), wrap(year2016day14.part2)),
    # 15: (wrap(year2016day15.part1), wrap(year2016day15.part2)),
    # 16: (wrap(year2016day16.part1), wrap(year2016day16.part2)),
    # 17: (wrap(year2016day17.part1), wrap(year2016day17.part2)),
    # 18: (wrap(year2016day18.part1), wrap(year2016day18.part2)),
    # 19: (wrap(year2016day19.part1), wrap(year2016day19.part2)),
    # 20: (wrap(year2016day20.part1), wrap(year2016day20.part2)),
    # 21: (wrap(year2016day21.part1), wrap(year2016day21.part2)),
    # 22: (wrap(year2016day22.part1), wrap(year2016day22.part2)),
    # 23: (wrap(year2016day23.part1), wrap(year2016day23.part2)),
    # 24: (wrap(year2016day24.part1), wrap(year2016day24.part2)),
    # 25: (wrap(year2016day25.part1), wrap(year2016day25.part2)),
  }.toTable,
  2017: {
    1: (wrap(year2017day01.part1), wrap(year2017day01.part2)),
    # 2: (wrap(year2017day02.part1), wrap(year2017day02.part2)),
    # 3: (wrap(year2017day03.part1), wrap(year2017day03.part2)),
    # 4: (wrap(year2017day04.part1), wrap(year2017day04.part2)),
    # 5: (wrap(year2017day05.part1), wrap(year2017day05.part2)),
    # 6: (wrap(year2017day06.part1), wrap(year2017day06.part2)),
    # 7: (wrap(year2017day07.part1), wrap(year2017day07.part2)),
    # 8: (wrap(year2017day08.part1), wrap(year2017day08.part2)),
    # 9: (wrap(year2017day09.part1), wrap(year2017day09.part2)),
    # 10: (wrap(year2017day10.part1), wrap(year2017day10.part2)),
    # 11: (wrap(year2017day11.part1), wrap(year2017day11.part2)),
    # 12: (wrap(year2017day12.part1), wrap(year2017day12.part2)),
    # 13: (wrap(year2017day13.part1), wrap(year2017day13.part2)),
    # 14: (wrap(year2017day14.part1), wrap(year2017day14.part2)),
    # 15: (wrap(year2017day15.part1), wrap(year2017day15.part2)),
    # 16: (wrap(year2017day16.part1), wrap(year2017day16.part2)),
    # 17: (wrap(year2017day17.part1), wrap(year2017day17.part2)),
    # 18: (wrap(year2017day18.part1), wrap(year2017day18.part2)),
    # 19: (wrap(year2017day19.part1), wrap(year2017day19.part2)),
    # 20: (wrap(year2017day20.part1), wrap(year2017day20.part2)),
    # 21: (wrap(year2017day21.part1), wrap(year2017day21.part2)),
    # 22: (wrap(year2017day22.part1), wrap(year2017day22.part2)),
    # 23: (wrap(year2017day23.part1), wrap(year2017day23.part2)),
    # 24: (wrap(year2017day24.part1), wrap(year2017day24.part2)),
    # 25: (wrap(year2017day25.part1), wrap(year2017day25.part2)),
  }.toTable,
  2018: {
    # 1: (wrap(year2018day01.part1), wrap(year2018day01.part2)),
    # 2: (wrap(year2018day02.part1), wrap(year2018day02.part2)),
    # 3: (wrap(year2018day03.part1), wrap(year2018day03.part2)),
    # 4: (wrap(year2018day04.part1), wrap(year2018day04.part2)),
    # 5: (wrap(year2018day05.part1), wrap(year2018day05.part2)),
    # 6: (wrap(year2018day06.part1), wrap(year2018day06.part2)),
    # 7: (wrap(year2018day07.part1), wrap(year2018day07.part2)),
    # 8: (wrap(year2018day08.part1), wrap(year2018day08.part2)),
    # 9: (wrap(year2018day09.part1), wrap(year2018day09.part2)),
    # 10: (wrap(year2018day10.part1), wrap(year2018day10.part2)),
    11: (wrap(year2018day11.part1), wrap(year2018day11.part2)),
    # 12: (wrap(year2018day12.part1), wrap(year2018day12.part2)),
    # 13: (wrap(year2018day13.part1), wrap(year2018day13.part2)),
    # 14: (wrap(year2018day14.part1), wrap(year2018day14.part2)),
    # 15: (wrap(year2018day15.part1), wrap(year2018day15.part2)),
    # 16: (wrap(year2018day16.part1), wrap(year2018day16.part2)),
    # 17: (wrap(year2018day17.part1), wrap(year2018day17.part2)),
    # 18: (wrap(year2018day18.part1), wrap(year2018day18.part2)),
    # 19: (wrap(year2018day19.part1), wrap(year2018day19.part2)),
    # 20: (wrap(year2018day20.part1), wrap(year2018day20.part2)),
    # 21: (wrap(year2018day21.part1), wrap(year2018day21.part2)),
    # 22: (wrap(year2018day22.part1), wrap(year2018day22.part2)),
    # 23: (wrap(year2018day23.part1), wrap(year2018day23.part2)),
    # 24: (wrap(year2018day24.part1), wrap(year2018day24.part2)),
    # 25: (wrap(year2018day25.part1), wrap(year2018day25.part2)),
  }.toTable,
  2019: {
    1: (wrap(year2019day01.part1), wrap(year2019day01.part2)),
    # 2: (wrap(year2019day02.part1), wrap(year2019day02.part2)),
    # 3: (wrap(year2019day03.part1), wrap(year2019day03.part2)),
    # 4: (wrap(year2019day04.part1), wrap(year2019day04.part2)),
    # 5: (wrap(year2019day05.part1), wrap(year2019day05.part2)),
    # 6: (wrap(year2019day06.part1), wrap(year2019day06.part2)),
    # 7: (wrap(year2019day07.part1), wrap(year2019day07.part2)),
    # 8: (wrap(year2019day08.part1), wrap(year2019day08.part2)),
    # 9: (wrap(year2019day09.part1), wrap(year2019day09.part2)),
    # 10: (wrap(year2019day10.part1), wrap(year2019day10.part2)),
    # 11: (wrap(year2019day11.part1), wrap(year2019day11.part2)),
    # 12: (wrap(year2019day12.part1), wrap(year2019day12.part2)),
    # 13: (wrap(year2019day13.part1), wrap(year2019day13.part2)),
    # 14: (wrap(year2019day14.part1), wrap(year2019day14.part2)),
    # 15: (wrap(year2019day15.part1), wrap(year2019day15.part2)),
    # 16: (wrap(year2019day16.part1), wrap(year2019day16.part2)),
    # 17: (wrap(year2019day17.part1), wrap(year2019day17.part2)),
    # 18: (wrap(year2019day18.part1), wrap(year2019day18.part2)),
    # 19: (wrap(year2019day19.part1), wrap(year2019day19.part2)),
    # 20: (wrap(year2019day20.part1), wrap(year2019day20.part2)),
    # 21: (wrap(year2019day21.part1), wrap(year2019day21.part2)),
    # 22: (wrap(year2019day22.part1), wrap(year2019day22.part2)),
    # 23: (wrap(year2019day23.part1), wrap(year2019day23.part2)),
    # 24: (wrap(year2019day24.part1), wrap(year2019day24.part2)),
    # 25: (wrap(year2019day25.part1), wrap(year2019day25.part2)),
  }.toTable,
  2020: {
    1: (wrap(year2020day01.part1), wrap(year2020day01.part2)),
    2: (wrap(year2020day02.part1), wrap(year2020day02.part2)),
    3: (wrap(year2020day03.part1), wrap(year2020day03.part2)),
    4: (wrap(year2020day04.part1), wrap(year2020day04.part2)),
    5: (wrap(year2020day05.part1), wrap(year2020day05.part2)),
    6: (wrap(year2020day06.part1), wrap(year2020day06.part2)),
    7: (wrap(year2020day07.part1), wrap(year2020day07.part2)),
    8: (wrap(year2020day08.part1), wrap(year2020day08.part2)),
    9: (wrap(year2020day09.part1), wrap(year2020day09.part2)),
    10: (wrap(year2020day10.part1), wrap(year2020day10.part2)),
    11: (wrap(year2020day11.part1), wrap(year2020day11.part2)),
    12: (wrap(year2020day12.part1), wrap(year2020day12.part2)),
    13: (wrap(year2020day13.part1), wrap(year2020day13.part2)),
    14: (wrap(year2020day14.part1), wrap(year2020day14.part2)),
    15: (wrap(year2020day15.part1), wrap(year2020day15.part2)),
    16: (wrap(year2020day16.part1), wrap(year2020day16.part2)),
    17: (wrap(year2020day17.part1), wrap(year2020day17.part2)),
    18: (wrap(year2020day18.part1), wrap(year2020day18.part2)),
    19: (wrap(year2020day19.part1), wrap(year2020day19.part2)),
    20: (wrap(year2020day20.part1), wrap(year2020day20.part2)),
    21: (wrap(year2020day21.part1), wrap(year2020day21.part2)),
    22: (wrap(year2020day22.part1), wrap(year2020day22.part2)),
    23: (wrap(year2020day23.part1), wrap(year2020day23.part2)),
    24: (wrap(year2020day24.part1), wrap(year2020day24.part2)),
    25: (wrap(year2020day25.part1), wrap(year2020day25.part2)),
  }.toTable,
}.toTable
