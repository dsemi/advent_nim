import sequtils
import sets
import strutils
import sugar

proc solve(f: (HashSet[char], HashSet[char]) -> HashSet[char], input: string): int =
  for group in input.split("\n\n"):
    result += group.split.mapIt(toHashSet(it)).foldl(f(a, b)).len

proc part1*(input: string): int =
  solve(union, input)

proc part2*(input: string): int =
  solve(intersection, input)
