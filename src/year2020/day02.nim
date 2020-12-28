import strutils

iterator parse(input: string): (int, int, char, string) =
  for line in input.splitlines:
    let parts = line.split(" ")
    let ns = parts[0].split("-")
    yield (ns[0].parseInt, ns[1].parseInt, parts[1][0], parts[2])

proc part1*(input: string): int =
  for (a, b, c, str) in parse(input):
    let cnt = str.count(c)
    if a <= cnt and cnt <= b:
      result += 1

proc part2*(input: string): int =
  for (a, b, c, str) in parse(input):
    if str[a-1] == c xor str[b-1] == c:
      result += 1
