import threadpool

{.passl: "-lssl -lcrypto".}
{.compile("src/year2016/md5.c", "-mavx2 -Ofast").}
proc md5sum(data: openArray[char], output: ptr char, stretch: csize_t) {.importc.}

const batchSize = 1000

proc hashNum(seed: string, n: int, num: int): array[32, char] =
  md5sum(seed & $n, addr result[0], uint(num))

proc idx(c: char): int =
  if c in '0'..'9':
    return int(c) - int('0')
  return int(c) - int('a') + 10

iterator findIndexes(seed: string, num: int = 0): int =
  var pot: array[16, seq[int]]
  for i1 in countup(0, int.high, batchSize):
    var arr = newSeq[FlowVar[array[32, char]]](batchSize)
    for i in 0 .. arr.high:
      arr[i] = spawn hashNum(seed, i+i1, num)
    for i in i1..<i1+batchSize:
      let hash = ^arr[i-i1]
      for j in hash.low..hash.high-4:
        if hash[j] == hash[j+1] and hash[j] == hash[j+2] and
           hash[j] == hash[j+3] and hash[j] == hash[j+4]:
          for v in pot[hash[j].idx]:
            if i - v <= 1000:
              yield v
          pot[hash[j].idx].setLen(0)
      for j in hash.low..hash.high-2:
        if hash[j] == hash[j+1] and hash[j] == hash[j+2]:
          pot[hash[j].idx].add(i)
          break

proc part1*(input: string): int =
  var c = 0
  for i in findIndexes(input):
    inc c
    if c == 64:
      return i

proc part2*(input: string): int =
  var c = 0
  for i in findIndexes(input, 2016):
    inc c
    if c == 64:
      return i
