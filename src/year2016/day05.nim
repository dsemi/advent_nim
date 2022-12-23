import md5
import strutils
import threadpool

const
  largeBatchSize = 8
  batchSize = 64000

proc helper(seed: string, start: int): seq[uint8] =
  for i in start .. start + batchSize:
    let h = (seed & $i).toMD5
    if h[0] == 0 and h[1] == 0 and h[2] < 16:
      result.add(h[2])

proc part1*(input: string): string =
  var
    res: array[8, string]
    j = 0
  for sz in countup(0, int.high, largeBatchSize * batchSize):
    var arr = newSeq[FlowVar[seq[uint8]]](largeBatchSize)
    for i in 0 .. arr.high:
      arr[i] = spawn helper(input, sz + i * batchSize)
    for grp in arr:
      for x in ^grp:
        res[j] = toHex(x.uint, 1).toLowerAscii
        inc j
        if j == 8:
          return res.join

proc helper2(seed: string, start: int): seq[(uint8, uint8)] =
  for i in start .. start + batchSize:
    let h = (seed & $i).toMD5
    if h[0] == 0 and h[1] == 0 and h[2] < 8:
      result.add((h[2], h[3] shr 4))

proc part2*(input: string): string =
  var
    res: array[8, string]
    j = 0
  for sz in countup(0, int.high, largeBatchSize * batchSize):
    var arr = newSeq[FlowVar[seq[(uint8, uint8)]]](largeBatchSize)
    for i in 0 .. arr.high:
      arr[i] = spawn helper2(input, sz + i * batchSize)
    for grp in arr:
      for (n, c) in ^grp:
        if res[n] == "":
          res[n] = toHex(c.uint, 1).toLowerAscii
          inc j
          if j == 8:
            return res.join
