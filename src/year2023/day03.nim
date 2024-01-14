import std/strutils

func isSymbol(data: openArray[char], i: int): bool =
  if i < 0 or i >= data.len:
    return false
  data[i] notin {'0'..'9', '.', '\n'}

proc part1*(data: string): int =
  let cols = data.find('\n') + 1
  var i: int
  while i < data.len:
    let v = data[i]
    if v in Digits:
      var n: int
      var adjToSymbol = isSymbol(data, i-cols-1) or
                        isSymbol(data, i-1) or
                        isSymbol(data, i+cols-1)
      while i < data.len and data[i] in Digits:
        adjToSymbol = adjToSymbol or
                      isSymbol(data, i-cols) or
                      isSymbol(data, i+cols)
        n = 10*n + data[i].ord - '0'.ord
        i += 1
      adjToSymbol = adjToSymbol or
                    isSymbol(data, i-cols) or
                    isSymbol(data, i) or
                    isSymbol(data, i+cols)
      if adjToSymbol:
        result += n
    else:
      inc i

func numStart(data: openArray[char], i: int): int =
  for j in countdown(i, 0):
    if data[j] notin Digits:
      break
    result = j

proc expandNum(data: openArray[char], start: int): int =
  for i in start..data.high:
    if data[i] notin Digits:
      break
    result = 10*result + data[i].ord - '0'.ord

proc part2*(data: string): int =
  let cols = data.find('\n') + 1
  let ds = @[-cols-1, -cols, -cols+1, -1, 1, cols-1, cols, cols+1]
  for i, v in data:
    if v != '*':
      continue
    var prev = -1
    var num = 0
    var partNums: array[2, int]
    var invalid = false
    for d in ds:
      let idx = i + d
      if idx < 0 or idx > data.high or data[i+d] notin Digits:
        continue
      let start = numStart(data, idx)
      if start == prev:
        continue
      prev = start
      partNums[num] = expandNum(data, start)
      num += 1
      if num > 2:
        break
    if num == 2:
      result += partNums[0] * partNums[1]
