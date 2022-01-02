import fusion/matching
import sequtils
import sets
import strutils
import sugar

import "../utils.nim"

proc parse(input: string): (HashSet[Coord], string) =
  [@dots, @instrs] := input.split("\n\n", 1)
  result[0] = collect(initHashSet):
    for dot in dots.splitlines:
      let pts = dot.split(',', 1)
      {(pts[0].parseInt, pts[1].parseInt)}
  result[1] = instrs

proc fold(paper: HashSet[Coord], instr: string): HashSet[Coord] =
  [@d, @ns] := instr.splitWhitespace[^1].split('=', 1)
  let n = ns.parseInt
  if d == "x":
    collect(initHashSet):
      for (x, y) in paper:
        {(min(x, 2 * n - x), y)}
  else:
    collect(initHashSet):
      for (x, y) in paper:
        {(x, min(y, 2 * n - y))}

proc part1*(input: string): int =
  let (paper, instrs) = parse(input)
  fold(paper, instrs.splitlines[0]).len

proc part2*(input: string): string =
  var (paper, instrs) = parse(input)
  for instr in instrs.splitlines:
    paper = fold(paper, instr)
  let (mx, my) = paper.foldl((max(a[0], b[0]), max(a[1], b[1])), (0, 0))
  var display = @[""]
  for y in 0..my:
    display.add((0..mx).toSeq.mapIt(if (it, y) in paper: '#' else: ' ').join)
  display.join("\n")
