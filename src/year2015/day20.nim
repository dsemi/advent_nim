import strutils

proc part1*(input: string): int =
  let n = input.parseInt
  let lim = n div 10
  var arr = newSeq[int](lim+1)
  for i in 1..lim:
    for j in countup(i, lim, i):
      arr[j] += 10*i
  for i, v in arr:
    if v >= n:
      return i

proc part2*(input: string): int =
  let n = input.parseInt
  let lim = n div 11
  var arr = newSeq[int](lim+1)
  for i in 1..lim:
    for j in countup(i, min(50*i, lim), i):
      arr[j] += 11*i
  for i, v in arr:
    if v >= n:
      return i
