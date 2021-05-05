import sequtils
import strutils
import sugar

proc calcSteps(f: (int) -> int, input: string): int =
  var ns = input.splitLines.map(parseInt)
  var i = 0
  while i >= ns.low and i <= ns.high:
    let val = ns[i]
    ns[i] = f(val)
    i += val
    inc result

proc part1*(input: string): int =
  calcSteps((x) => x + 1, input)

proc part2*(input: string): int =
  calcSteps((x) => (if x >= 3: x - 1 else: x + 1), input)
