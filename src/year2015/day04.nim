import itertools
import md5
import threadpool
{.experimental: "parallel".}

proc part1*(input: string): int =
  for i in count(0):
    let h = (input & $i).toMD5
    if h[0] == 0 and h[1] == 0 and h[2] < 16:
      return i

const
  largeBatchSize = 4000
  batchSize = 1000

proc helper(seed: string, start: int): int =
  for i in start ..< start + batchSize:
    let h = (seed & $i).toMD5
    if h[0] == 0 and h[1] == 0 and h[2] == 0:
      return i

proc part2*(input: string): int =
  for sz in countup(0, int.high, largeBatchSize * batchSize):
    var arr = newSeq[int](largeBatchSize)
    parallel:
      for i in 0..arr.high:
        arr[i] = spawn helper(input, sz + i * batchSize)
    for x in arr:
      if x > 0:
        return x
