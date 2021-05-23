import "intcode"

proc part1*(input: string): int =
  input.parse.runWithInput([1])[^1]

proc part2*(input: string): int =
  input.parse.runWithInput([5])[^1]
