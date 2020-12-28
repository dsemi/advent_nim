import macros
import os
import strformat
import strutils
import sugar
import tables
import terminal
import times

macro imports(s: static[string]): untyped =
  result = newStmtList()
  for _, d in walkDir(".", relative=true):
    if d.startswith("year"):
      for _, f in walkDir(d, relative=true):
        if f.startswith("day"):
          let module = fmt"{d}/{f[0 ..< ^4]}"
          let alias = module.replace("/", "")
          result.add(newNimNode(nnkImportStmt).add(infix(newIdentNode(module), "as", newIdentNode(alias))))

imports("wat")

proc wrap(f: (string) -> string): (string) -> string = f

proc wrap(f: (string) -> int): (string) -> string =
  proc inner(inp: string): string = $f(inp)
  result = inner

let problems = {
  2020: {
    # 1: (wrap(year2020day1.part1), wrap(year2020day1.part2)),
    # 2: (wrap(year2020day2.part1), wrap(year2020day2.part2)),
    # 3: (wrap(year2020day3.part1), wrap(year2020day3.part2)),
    # 4: (wrap(year2020day4.part1), wrap(year2020day4.part2)),
    # 5: (wrap(year2020day5.part1), wrap(year2020day5.part2)),
    # 6: (wrap(year2020day6.part1), wrap(year2020day6.part2)),
    # 7: (wrap(year2020day7.part1), wrap(year2020day7.part2)),
    # 8: (wrap(year2020day8.part1), wrap(year2020day8.part2)),
    # 9: (wrap(year2020day9.part1), wrap(year2020day9.part2)),
    # 10: (wrap(year2020day10.part1), wrap(year2020day10.part2)),
    # 11: (wrap(year2020day11.part1), wrap(year2020day11.part2)),
    # 12: (wrap(year2020day12.part1), wrap(year2020day12.part2)),
    # 13: (wrap(year2020day13.part1), wrap(year2020day13.part2)),
    # 14: (wrap(year2020day14.part1), wrap(year2020day14.part2)),
    # 15: (wrap(year2020day15.part1), wrap(year2020day15.part2)),
    # 16: (wrap(year2020day16.part1), wrap(year2020day16.part2)),
    # 17: (wrap(year2020day17.part1), wrap(year2020day17.part2)),
    # 18: (wrap(year2020day18.part1), wrap(year2020day18.part2)),
    # 19: (wrap(year2020day19.part1), wrap(year2020day19.part2)),
    # 20: (wrap(year2020day20.part1), wrap(year2020day20.part2)),
    21: (wrap(year2020day21.part1), wrap(year2020day21.part2)),
    22: (wrap(year2020day22.part1), wrap(year2020day22.part2)),
    23: (wrap(year2020day23.part1), wrap(year2020day23.part2)),
    24: (wrap(year2020day24.part1), wrap(year2020day24.part2)),
    25: (wrap(year2020day25.part1), wrap(year2020day25.part2)),
  }.toTable,
}.toTable

proc colorizeTime(t: float): string =
  let s = fmt"{t:.3f}"
  if t < 0.5:
    return ansiForegroundColorCode(fgGreen) & s & ansiResetCode
  if t < 1.0:
    return ansiForegroundColorCode(fgYellow) & s & ansiResetCode
  return ansiForegroundColorCode(fgRed) & s & ansiResetCode

proc timeit(f: (string) -> string, inp: string): (string, float) =
  let startT = cpuTime()
  let ans = f(inp)
  let endT = cpuTime()
  return (ans, endT - startT)

proc run(year: int, day: int): float =
  let contents = readFile(fmt"inputs/{year}/input{day}.txt").strip
  echo fmt"Day {day}"
  let outstr = "Part $1: $2  Elapsed time $3 seconds"
  let (ans1, t1) = timeit(problems[year][day][0], contents)
  echo outstr.format(1, align(ans1, 32), colorizeTime(t1))
  let (ans2, t2) = timeit(problems[year][day][1], contents)
  echo outstr.format(2, align(ans2, 32), colorizeTime(t2))
  t1 + t2

let year = commandLineParams()[0].parseInt
var total = 0.0
for day in commandLineParams()[1 .. ^1]:
  let day = day.parseInt
  total += run(year, day)
echo fmt"Total: {total:53.3f} seconds"
