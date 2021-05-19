import fusion/matching
import sequtils
import strutils

iterator parse(input: string): (int, int, char, string) =
  for line in input.splitlines:
    [@ns, @c, @str] := line.split(" ")
    [@a, @b] := ns.split('-').map(parseInt)
    yield (a, b, c[0], str)

proc part1*(input: string): int =
  for (a, b, c, str) in parse(input):
    let cnt = str.count(c)
    result += int(a <= cnt and cnt <= b)

proc part2*(input: string): int =
  for (a, b, c, str) in parse(input):
    result += int(str[a-1] == c xor str[b-1] == c)
