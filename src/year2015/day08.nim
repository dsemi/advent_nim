import strutils

proc part1*(input: string): int =
  for line in input.splitlines:
    var i = 0
    result += 2
    while i < line.len:
      if line[i] == '\\':
        if line[i+1] == 'x':
          result += 3
          i += 3
        else:
          result += 1
          i += 1
      i += 1

proc part2*(input: string): int =
  for line in input.splitlines:
    result += 2 + line.count('\\') + line.count('"')
