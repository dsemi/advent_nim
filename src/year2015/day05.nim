import sequtils
import strutils

proc part1*(input: string): int =
  for line in input.splitlines:
    if line.countIt(it in "aeiou") >= 3 and
       line.zip(line[1..^1]).anyIt(it[0] == it[1]) and
       not ["ab", "cd", "pq", "xy"].anyIt(it in line):
      inc result

proc part2*(input: string): int =
  for line in input.splitlines:
    block outer:
      for i in line.low .. line.high - 3:
        for j in i+2 .. line.high - 1:
          if line[i] == line[j] and line[i+1] == line[j+1]:
            if line.zip(line[2..^1]).anyIt(it[0] == it[1]):
              inc result
            break outer
