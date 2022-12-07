import strutils

proc getAllSizes(input: string): seq[int] =
  template moveUp() =
    fstree[^2] += fstree[^1]
    result.add(fstree.pop)
  var fstree = @[0]
  for line in input.splitLines:
    if line.startsWith("$ cd "):
      if line.endsWith("/"):
        while fstree.len > 1:
          moveUp
      elif line.endsWith(".."):
        moveUp
      else:
        fstree.add(0)
    elif line.find({'0'..'9'}) == 0:
      fstree[^1] += line.split[0].parseInt
  while fstree.len > 1:
    moveUp
  result.add(fstree[0])

proc part1*(input: string): int =
  for size in input.getAllSizes:
    if size <= 100000:
      result += size

proc part2*(input: string): int =
  let sizes = input.getAllSizes
  let target = sizes[^1] - 40000000
  result = int.high
  for size in sizes:
    if size >= target:
      result = min(result, size)
