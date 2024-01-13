import checksums/md5
import std/atomics
import std/cpuinfo

const batchSize = 8000

type Shared = ref object
  prefix: string
  done: Atomic[bool]
  counter: Atomic[uint32]
  sol: Atomic[uint32]

proc worker(arg: (Shared, uint8)) {.thread.} =
  let (s, v) = arg
  while not s.done.load(moRelaxed):
    let offset = s.counter.fetchAdd(batchSize, moRelaxed)
    for n in 0'u32 ..< batchSize:
      let i = offset + n
      let h = (s.prefix & $i).toMD5
      if h[0] == 0 and h[1] == 0 and h[2] <= v:
        var val = s.sol.load(moRelaxed)
        while i < val and not s.sol.compareExchangeWeak(val, i, moRelaxed):
          discard
        s.done.store(true, moRelaxed)

proc solve(input: string, v: uint8): uint32 =
  let s = Shared(prefix: input)
  s.sol.store(uint32.high)
  var thr: array[20, Thread[(Shared, uint8)]]
  for i in 0 ..< countProcessors():
    createThread(thr[i], worker, (s, v))
  joinThreads(thr)
  s.sol.load

proc part1*(input: string): uint32 =
  input.solve(15)

proc part2*(input: string): uint32 =
  input.solve(0)
