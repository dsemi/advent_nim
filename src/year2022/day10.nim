import strutils
import sequtils

iterator run(input: string): (int, int) =
  var (cycle, x) = (1, 1)
  for line in input.splitLines:
    let pts = line.split
    yield (cycle, x)
    if pts[0] == "addx":
      cycle += 1
      yield (cycle, x)
      cycle += 1
      x += pts[1].parseInt
    elif pts[0] == "noop":
      cycle += 1

proc part1*(input: string): int =
  for (cycle, x) in input.run:
    if cycle in {20, 60, 100, 140, 180, 220}:
      result += cycle * x
    if cycle >= 220:
      break

proc part2*(input: string): string =
  var lns = newSeqWith(6, newSeq[char](40))
  for (cycle, x) in input.run:
    let (r, pos) = ((cycle - 1) div 40, (cycle - 1) mod 40)
    lns[r][pos] = if (pos - x).abs <= 1: '#' else: ' '
  "\n" & lns.mapIt(it.join).join("\n")
