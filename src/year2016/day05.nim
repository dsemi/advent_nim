import std/algorithm
import checksums/md5
import std/cpuinfo
import std/locks
import std/strutils
import threading/atomics

const batchSize = 8000

type Shared = object
  prefix: string
  last: Atomic[uint32]
  counter: Atomic[uint32]
  lock: Lock
  finishedAt: seq[uint32]
  sol: seq[uint8]

proc worker(s: ptr Shared) {.thread.} =
  while true:
    let offset = s[].counter.fetchAdd(batchSize, Relaxed)
    if offset > s[].last.load(Relaxed):
      break
    for n in 0'u32 ..< batchSize:
      let i = offset + n
      let h = (s[].prefix & $i).toMD5
      if h[0] == 0 and h[1] == 0 and h[2] < 16:
        s[].lock.withLock:
          var idx = s[].finishedAt.upperBound(i)
          if idx >= 8:
            break
          s[].finishedAt.insert(i, idx)
          s[].sol.insert(h[2], idx)
          if s[].sol.len == 8:
            s[].last.store(s[].finishedAt[7])

proc part1*(input: string): string =
  var s = Shared(prefix: input)
  s.last.store(uint32.high)
  var thrs = newSeq[Thread[ptr Shared]](countProcessors())
  for i in 0..thrs.high:
    createThread(thrs[i], worker, addr s)
  joinThreads(thrs)
  for c in s.sol:
    result.add toHex(c, 1).toLowerAscii

type Shared2 = object
  prefix: string
  last: Atomic[uint32]
  counter: Atomic[uint32]
  lock: Lock
  complete: set[0..7]
  finishedAt: array[8, uint32]
  sol: array[8, uint8]

proc worker2(s: ptr Shared2) {.thread.} =
  while true:
    let offset = s[].counter.fetchAdd(batchSize, Relaxed)
    if offset > s[].last.load(Relaxed):
      break
    for n in 0'u32 ..< batchSize:
      let i = offset + n
      let h = (s[].prefix & $i).toMD5
      if h[0] == 0 and h[1] == 0 and h[2] < 8:
        var idx = h[2]
        var curr = h[3] shr 4
        s[].lock.withLock:
          if s[].finishedAt[idx] == 0 or s[].finishedAt[idx] > i:
            s[].finishedAt[idx] = i
            s[].sol[idx] = curr
            s[].complete.incl(idx)
            if s[].complete.card == 8:
              s[].last.store(i)

proc part2*(input: string): string =
  var s = Shared2(prefix: input)
  s.last.store(uint32.high)
  var thrs = newSeq[Thread[ptr Shared2]](countProcessors())
  for i in 0..thrs.high:
    createThread(thrs[i], worker2, addr s)
  joinThreads(thrs)
  for c in s.sol:
    result.add toHex(c, 1).toLowerAscii
