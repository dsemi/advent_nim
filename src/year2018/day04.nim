import algorithm
import math
import sequtils
import strutils
import sugar
import tables
import unpack

type
  RecordKind = enum
    GuardChange, SleepToggle

  Record = object
    case kind: RecordKind
    of GuardChange: guardNum: int
    of SleepToggle: minute: int

proc parseRecords(input: string): seq[Record] =
  for line in toSeq(input.splitLines).sorted:
    [time, rest] <- line.split("] ")
    if rest.startsWith("Guard"):
      result.add(Record(kind: GuardChange, guardNum: rest.filter(isDigit).join.parseInt))
    else:
      result.add(Record(kind: SleepToggle, minute: time[time.rfind(':')+1..^1].parseInt))

proc guardSleepFreqs(records: seq[Record]): Table[int, seq[int]] =
  var guard, lastM, st: int
  for record in records:
    if record.kind == GuardChange:
      if lastM > 0:
        for i in lastM..<60:
          result[guard][i] += st
      guard = record.guardNum
      st = 0
      lastM = 0
      if guard notin result:
        result[guard] = newSeq[int](60)
    else:
      for i in lastM..<record.minute:
        result[guard][i] += st
      st = st xor 1
      lastM = record.minute
  for i in lastM..<60:
    result[guard][i] += st

proc part1*(input: string): int =
  let sleepFreqs = input.parseRecords.guardSleepFreqs
  let n = toSeq(sleepFreqs.pairs).mapIt((it[1].sum, it[0])).max[1]
  n * sleepFreqs[n].maxIndex

proc part2*(input: string): int =
  let sleepFreqs = input.parseRecords.guardSleepFreqs
  let m = toSeq(sleepFreqs.pairs)
  .map((kv) => kv[1].zip(toSeq(0..kv[1].high)).mapIt((it[0], it[1], kv[0])).max).max
  m[1] * m[2]
