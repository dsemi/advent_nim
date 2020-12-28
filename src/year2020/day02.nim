import sequtils
import strutils
import unpack

iterator parse(input: string): (int, int, char, string) =
  for line in input.splitlines:
    [ns, c, str] <- line.split(" ")
    [a, b] <- ns.split('-').map(parseInt)
    yield (a, b, c[0], str)

proc part1*(input: string): int =
  for (a, b, c, str) in parse(input):
    let cnt = str.count(c)
    if a <= cnt and cnt <= b:
      result += 1

proc part2*(input: string): int =
  for (a, b, c, str) in parse(input):
    if str[a-1] == c xor str[b-1] == c:
      result += 1
