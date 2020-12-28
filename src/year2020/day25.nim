import sequtils
import strutils
import unpack

proc part1*(input: string): int =
  [card, door] <- input.splitlines.map(parseInt)
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
  nil
