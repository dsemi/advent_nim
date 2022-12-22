import md5
import threadpool

proc part1*(input: string): int =
  for i in 0 .. int.high:
    let h = (input & $i).toMD5
    if h[0] == 0 and h[1] == 0 and h[2] < 16:
      return i

const
  largeBatchSize = 8
  batchSize = 8000

proc helper(seed: string, start: int): int =
  for i in start ..< start + batchSize:
    let h = (seed & $i).toMD5
    if h[0] == 0 and h[1] == 0 and h[2] == 0:
      return i

proc part2*(input: string): int =
  for sz in countup(0, int.high, largeBatchSize * batchSize):
    var arr = newSeq[FlowVar[int]](largeBatchSize)
    for i in 0 .. arr.high:
      arr[i] = spawn helper(input, sz + i * batchSize)
    for fx in arr:
      let x = ^fx
      if x > 0:
        return x
