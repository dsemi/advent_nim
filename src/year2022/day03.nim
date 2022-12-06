import sequtils
import std/setutils
import strutils

const s = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

proc part1*(input: string): int =
  for line in input.splitLines:
    let a = toSet(line[0 ..< line.len div 2])
    let b = toSet(line[line.len div 2 .. ^1])
    result += 1 + s.find(toSeq(a * b)[0])

proc part2*(input: string): int =
  let comps = input.splitLines
  for i in countup(0, comps.high, 3):
    let a = toSet(comps[i])
    let b = toSet(comps[i+1])
    let c = toSet(comps[i+2])
    result += 1 + s.find(toSeq(a * b * c)[0])
