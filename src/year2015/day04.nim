import itertools
import md5

proc part1*(input: string): int =
  for i in count(0):
    let h = (input & $i).toMD5
    if h[0] == 0 and h[1] == 0 and h[2] < 16:
      return i

proc part2*(input: string): int =
  for i in count(0):
    let h = (input & $i).toMD5
    if h[0] == 0 and h[1] == 0 and h[2] == 0:
      return i
