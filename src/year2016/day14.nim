import md5
import tables
import threadpool
{.experimental: "parallel".}

const batchSize = 1000

proc hashNum(seed: string, n: int, num: int): string =
  result = (seed & $n).getMD5
  for _ in 1..num:
    result = result.getMD5

iterator findIndexes(seed: string, num: int = 0): int =
  var pot: Table[char, seq[int]]
  for i1 in countup(0, int.high, batchSize):
    var arr = newSeq[FlowVar[string]](batchSize)
    parallel:
      for i in 0 .. arr.high:
        arr[i] = spawn hashNum(seed, i+i1, num)
    for i in i1..<i1+batchSize:
      let hash = ^arr[i-i1]
      var sent: set[char]
      for j in hash.low..hash.high-4:
        if hash[j] == hash[j+1] and hash[j] == hash[j+2] and
           hash[j] == hash[j+3] and hash[j] == hash[j+4] and
           hash[j] in pot and hash[j] notin sent:
          sent.incl(hash[j])
          for v in pot[hash[j]]:
            if i - v <= 1000:
              yield v
          pot[hash[j]] = @[]
      for j in hash.low..hash.high-2:
        if hash[j] == hash[j+1] and hash[j] == hash[j+2]:
          pot.mgetOrPut(hash[j], @[]).add(i)
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
