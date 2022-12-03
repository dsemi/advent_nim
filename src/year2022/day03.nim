import strutils
import sequtils

const s = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

proc part1*(input: string): int =
  for line in input.splitLines:
    var a, b: set[char]
    for x in line[0 ..< line.len div 2]: a.incl(x)
    for x in line[line.len div 2 .. ^1]: b.incl(x)
    result += 1 + s.find(toSeq(a * b)[0])

proc part2*(input: string): int =
  let comps = input.splitLines
  for i in countup(0, comps.len - 3, 3):
    var a, b, c: set[char]
    for x in comps[i]: a.incl(x)
    for x in comps[i+1]: b.incl(x)
    for x in comps[i+2]: c.incl(x)
    result += 1 + s.find(toSeq(a * b * c)[0])
