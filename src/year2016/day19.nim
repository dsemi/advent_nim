import math
import strutils

# Josephus
proc part1*(input: string): int =
  let n = input.parseInt
  1 + 2 * (n - 2 ^ n.float.log2.int)

# Weird Josephus
proc part2*(input: string): int =
  let n = input.parseInt
  let p3 = 3 ^ log(n.float, 3).int
  let ans = n - p3
  let ans2 = ans + max(0, ans - p3)
  if ans2 == 0: p3 else: ans
