import algorithm
import sequtils
import strscans
import strutils

proc moveStacks(input: string, inOrder: bool): string =
  let pts = input.split("\n\n")
  let crates = reversed(pts[0].splitLines)
  var stacks = newSeqWith((crates[0].len + 1) div 4, newSeq[char]())
  for line in crates:
    for i in countup(1, line.high, 4):
      if line[i] in {'A'..'Z'}:
        stacks[i div 4].add(line[i])
  for line in pts[1].splitLines:
    var n, a, b: int
    doAssert line.scanf("move $i from $i to $i", n, a, b)
    if inOrder:
      stacks[b-1].add(stacks[a-1][^n..^1])
      stacks[a-1].setLen(stacks[a-1].len - n)
    else:
      for _ in 1..n:
        stacks[b-1].add(stacks[a-1].pop)
  for stack in stacks:
    result.add(stack[^1])

proc part1*(input: string): string =
  input.moveStacks(false)

proc part2*(input: string): string =
  input.moveStacks(true)
