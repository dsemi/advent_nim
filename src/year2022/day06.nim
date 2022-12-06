import sequtils

proc solve(input: string, nchars: int): int =
  for i in 0..input.len-nchars:
    if input[i ..< i+nchars].deduplicate.len == nchars:
      return i + nchars

proc part1*(input: string): int =
  input.solve(4)

proc part2*(input: string): int =
  input.solve(14)
