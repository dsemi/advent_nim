import strutils

proc digits(n: int): seq[int] {.inline.} =
  if n < 10:
    return @[n]
  return @[1, n mod 10]

iterator recipes(): char =
  var rs = @[3, 7]
  for r in rs:
    yield (r + '0'.ord).chr
  var (elf1, elf2) = (0, 1)
  while true:
    let elf1Score = rs[elf1]
    let elf2Score = rs[elf2]
    let newR = digits(elf1Score + elf2Score)
    for r in newR:
      yield (r + '0'.ord).chr
    rs.add(newR)
    elf1 = (elf1Score + elf1 + 1) mod rs.len
    elf2 = (elf2Score + elf2 + 1) mod rs.len

proc part1*(input: string): string =
  var n = input.parseInt
  for r in recipes():
    if n <= -10:
      break
    elif n <= 0:
      result &= r
    dec n

proc part2*(input: string): int =
  result = -input.len
  var rs: string
  for r in recipes():
    inc result
    if rs.len < input.len:
      rs = rs & r
    else:
      rs = rs[1..^1] & r
    if rs == input:
      break
