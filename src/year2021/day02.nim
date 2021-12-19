import fusion/matching
import strutils

proc run(input: string): (int, int, int) =
  var horz, depth, aim = 0
  for line in input.splitlines:
    [@cmd, @ns] := line.split(' ', 1)
    let n = ns.parseInt
    case cmd:
      of "forward":
        horz += n
        depth += aim * n
      of "down":
        aim += n
      of "up":
        aim -= n
      else:
        raiseAssert "Bad cmd: " & line
  (horz, depth, aim)

proc part1*(input: string): int =
  let (horz, _, depth) = run(input)
  horz * depth

proc part2*(input: string): int =
  let (horz, depth, _) = run(input)
  horz * depth
