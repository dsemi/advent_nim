import strutils

proc react(s: string): int =
  var chs: seq[char]
  for c in s:
    if chs.len > 0 and chs[^1] != c and chs[^1].toLowerAscii == c.toLowerAscii:
      discard chs.pop
    else:
      chs.add(c)
  chs.len

proc part1*(input: string): int =
  input.react

proc part2*(input: string): int =
  result = int.high
  for c in 'a'..'z':
    result = min(result, input.replace($c).replace($c.toUpperAscii).react)
