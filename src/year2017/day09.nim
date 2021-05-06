proc process(s: string): (int, int) =
  var
    score = 0
    depth = 0
    inGarbage = false
    garbageCount = 0
    ignoreNext = false
  for x in s:
    if ignoreNext:
      ignoreNext = false
    elif inGarbage:
      case x
      of '!': ignoreNext = true
      of '>': inGarbage = false
      else: garbageCount += 1
    elif x == '}':
      score += depth
      depth -= 1
    elif x == '{':
      depth += 1
    elif x == '<':
      inGarbage = true
  (score, garbageCount)

proc part1*(input: string): int =
  input.process[0]

proc part2*(input: string): int =
  input.process[1]
