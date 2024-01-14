import std/sequtils
import std/strutils

proc countWins(line: string): int =
  let line = line[line.find(':') + 2 .. ^1]
  let pipeIdx = line.find('|')
  var wins: set[0..99]
  for w in line[0 ..< pipeIdx].splitWhitespace:
    wins.incl(w.parseInt)
  for n in line[pipeIdx+1 .. ^1].splitWhitespace:
    if n.parseInt in wins:
      inc result

proc part1*(input: string): int =
  for line in input.splitLines:
    let wins = line.countWins
    if wins > 0:
      result += 1 shl (wins - 1)

proc part2*(input: string): int =
  let lines = input.splitLines
  var cards = newSeqWith(lines.len, 1)
  for i, line in lines:
    let wins = line.countWins
    for j in 1..wins:
      cards[i+j] += cards[i]
  for c in cards:
    result += c
