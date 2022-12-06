import sequtils

proc solve(input: string, nchars: int): int =
  for i in nchars..input.len:
    if input[i-nchars ..< i].deduplicate.len == nchars:
      return i

proc part1*(input: string): int =
  input.solve(4)

proc part2*(input: string): int =
  input.solve(14)
