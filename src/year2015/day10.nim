import sequtils

proc lookAndSay(s: seq[char]): seq[char] =
  var curr = s[0]
  var cnt = 0
  for c in s:
    if c == curr:
      cnt += 1
    else:
      result.add($cnt)
      result.add(curr)
      curr = c
      cnt = 1
  result.add($cnt)
  result.add(curr)

proc part1*(input: string): int =
  var s = toSeq(input)
  for _ in 1..40:
    s = lookAndSay(s)
  s.len

proc part2*(input: string): int =
  var s = toSeq(input)
  for _ in 1..50:
    s = lookAndSay(s)
  s.len
