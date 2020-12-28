import strutils

proc part1*(input: string): int =
  let ns = input.splitlines
  let card = ns[0].parseInt
  let door = ns[1].parseInt
  var n, cardn, doorn = 1
  while true:
    n = n * 7 mod 20201227
    cardn = cardn * card mod 20201227
    doorn = doorn * door mod 20201227
    if n == card:
      return doorn
    if n == door:
      return cardn

proc part2*(input: string): string =
  ""
