import re
import sequtils
import strutils

proc part1*(input: string): int =
  for line in input.splitlines:
    if line.countIt(it in "aeiou") >= 3 and
       re"(.)\1" in line and
       not ["ab", "cd", "pq", "xy"].anyIt(it in line):
      result += 1

proc part2*(input: string): int =
  for line in input.splitlines:
    if re"(.)(.).*\1\2" in line and re"(.).\1" in line:
      result += 1
