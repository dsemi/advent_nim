import strutils

iterator recipes(): char =
  var rs = @[3, 7]
  for r in rs:
    yield (r + '0'.ord).chr
  var (elf1, elf2) = (0, 1)
  while true:
    let elf1Score = rs[elf1]
    let elf2Score = rs[elf2]
    let tot = elf1Score + elf2Score
    if tot >= 10:
      let m = tot mod 10
      rs.add(1)
      rs.add(m)
      yield '1'
      yield (m + '0'.ord).chr
    else:
      rs.add(tot)
      yield (tot + '0'.ord).chr
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
    rs &= r
    if rs.endsWith(input):
      break
