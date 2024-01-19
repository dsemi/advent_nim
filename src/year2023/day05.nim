import std/enumerate
import std/sequtils
import std/strutils

proc parseSeeds(line: string): seq[uint32] =
  for seed in line[7..^1].splitWhitespace:
    result.add seed.parseInt.uint32

proc parseStage(input: string): seq[array[3, uint32]] =
  for line in input[input.find('\n')+1..^1].splitLines:
    var row: array[3, uint32]
    for i, n in enumerate(line.splitWhitespace):
      row[i] = n.parseInt.uint32
    row[2] += row[1]
    result.add row

proc part1*(input: string): uint32 =
  let parts = input.split("\n\n")
  var seeds = parseSeeds(parts[0])
  let stages = parts[1..^1].map(parseStage)
  for stage in stages:
    for i, seed in seeds:
      for s in stage:
        let (dest, start, last) = (s[0], s[1], s[2])
        if start <= seed and seed < last:
          seeds[i] += dest - start
          break
  seeds.min

proc part2*(input: string): uint32 =
  let parts = input.split("\n\n")
  let seeds = parseSeeds(parts[0])
  let stages = parts[1..^1].map(parseStage)
  result = uint32.high
  for i in countUp(0, seeds.high, 2):
    var intervals = @[[seeds[i], seeds[i] + seeds[i+1]]]
    var nextStage = newSeq[array[2, uint32]]()
    var keepTrying = newSeq[array[2, uint32]]()
    for stage in stages:
      for s in stage:
        let (dest, s2, e2) = (s[0], s[1], s[2])
        for interval in intervals:
          let (s1, e1) = (interval[0], interval[1])
          let x1 = max(s1, s2)
          let x2 = min(e1, e2)
          if x1 < x2:
            nextStage.add [x1 + dest - s2, x2 + dest - s2]
            if s1 < x1:
              keepTrying.add [s1, x1]
            if x2 < e1:
              keepTrying.add [x2, e1]
          else:
            keepTrying.add interval
        swap(intervals, keepTrying)
        keepTrying.setLen(0)
      intervals.add nextStage
      nextStage.setLen(0)
    for interval in intervals:
      result = min(result, interval[0])
