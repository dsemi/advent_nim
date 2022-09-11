import strutils

proc part1*(input: string): int =
  let step = input.parseInt
  var list = @[0]
  var idx = 0
  for v in 1..2017:
    idx = (idx + step) mod v + 1
    list.insert(v, idx)
  list[idx+1]

proc part2*(input: string): int =
  let step = input.parseInt
  var pos, n, valAft0: int
  while n < 50_000_000:
    if pos == 1:
      valAft0 = n
    let skip = (n - pos) div step + 1
    n += skip
    pos = (pos + skip * (step + 1) - 1) mod n + 1
  valAft0
