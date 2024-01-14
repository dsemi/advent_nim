import std/strutils

proc part1*(input: string): int =
  for line in input.splitLines:
    result += 10 * (line[line.find(Digits)].ord - '0'.ord)
    result += line[line.rfind(Digits)].ord - '0'.ord

const Words = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]

proc part2*(input: string): int =
  for line in input.splitLines:
    var line = line
    block tenLoop:
      while true:
        if line[0] in Digits:
          result += 10 * (line[0].ord - '0'.ord)
          break
        for i, num in Words:
          if line.startsWith(num):
            result += 10 * (i + 1)
            break tenLoop
        line = line[1..^1]
    block oneLoop:
      while true:
        if line[^1] in Digits:
          result += line[^1].ord - '0'.ord
          break
        for i, num in Words:
          if line.endsWith(num):
            result += i + 1
            break oneLoop
        line = line[0..^2]
