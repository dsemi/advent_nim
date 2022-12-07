import strutils

type
  D = ref object
    dirs: seq[D]
    size: int

proc getAllSizes(input: string): seq[int] =
  template moveUp() =
    result.add(fstree[^1].size)
    fstree[^2].size += fstree[^1].size
    discard fstree.pop
  var fstree = @[D()]
  for line in input.splitLines:
    if line.startsWith("$ cd "):
      if line.endsWith("/"):
        while fstree.len > 1:
          moveUp
      elif line.endsWith(".."):
        moveUp
      else:
        let sub = D()
        fstree[^1].dirs.add(sub)
        fstree.add(sub)
    elif line.find({'0'..'9'}) == 0:
      fstree[^1].size += line.split[0].parseInt
  while fstree.len > 1:
    moveUp
  result.add(fstree[0].size)

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
