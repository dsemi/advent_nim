import checksums/md5
import std/cpuinfo
import threading/atomics
import threading/smartptrs

const batchSize = 8000

type Shared = object
  prefix: string
  done: Atomic[bool]
  counter: Atomic[uint32]
  sol: Atomic[uint32]

proc worker(arg: (SharedPtr[Shared], uint8)) {.thread.} =
  let (s, v) = arg
  while not s[].done.load(Relaxed):
    let offset = s[].counter.fetchAdd(batchSize, Relaxed)
    for n in 0'u32 ..< batchSize:
      let i = offset + n
      let h = (s[].prefix & $i).toMD5
      if h[0] == 0 and h[1] == 0 and h[2] <= v:
        var val = s[].sol.load(Relaxed)
        while i < val and not s[].sol.compareExchangeWeak(val, i, Relaxed):
          discard
        s[].done.store(true, Relaxed)

proc solve(input: string, v: uint8): uint32 =
  let s = newSharedPtr(Shared(prefix: input))
  s[].sol.store(uint32.high)
  var thr: array[20, Thread[(SharedPtr[Shared], uint8)]]
  doAssert countProcessors() < thr.len
  for i in 0 ..< countProcessors():
    createThread(thr[i], worker, (s, v))
  joinThreads(thr)
  s[].sol.load

proc part1*(input: string): uint32 =
  input.solve(15)

proc part2*(input: string): uint32 =
  input.solve(0)
