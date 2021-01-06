import strutils

proc lookAndSay(s: string): string =
  var curr = s[0]
  var cnt = 0
  var outp = newSeq[string]()
  for c in s:
    if c == curr:
      cnt += 1
    else:
      outp.add($cnt)
      outp.add($curr)
      curr = c
      cnt = 1
  outp.add($cnt)
  outp.add($curr)
  join(outp, "")

proc part1*(input: string): int =
  var s = input
  for _ in 1..40:
    s = lookAndSay(s)
  s.len

proc part2*(input: string): int =
  var s = input
  for _ in 1..50:
    s = lookAndSay(s)
  s.len
