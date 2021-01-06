proc part1*(input: string): int =
  for c in input:
    result += (if c == '(': 1 else: -1)

proc part2*(input: string): int =
  for i, c in input:
    result += (if c == '(': 1 else: -1)
    if result < 0:
      return i+1
