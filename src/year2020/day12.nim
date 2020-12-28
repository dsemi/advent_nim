import strutils

import "../utils"

proc travel(start: Coord, moveWay: bool, input: string): int =
  var st = @[(0, 0), start]
  for line in input.splitlines:
    let cmd = line[0]
    let n = line[1 .. ^1].parseInt
    case cmd:
      of 'N':
        st[int(moveWay)] += (0, n)
      of 'S':
        st[int(moveWay)] += (0, -n)
      of 'E':
        st[int(moveWay)] += (n, 0)
      of 'W':
        st[int(moveWay)] += (-n, 0)
      of 'L', 'R':
        assert n mod 90 == 0
        st[1] = st[1] * (if cmd == 'R': (0, -1) else: (0, 1))^(n div 90)
      of 'F':
        st[0] += n * st[1]
      else:
        discard
  return abs(st[0][0]) + abs(st[0][1])

proc part1*(input: string): int =
  travel((1, 0), false, input)

proc part2*(input: string): int =
  travel((10, 1), true, input)
