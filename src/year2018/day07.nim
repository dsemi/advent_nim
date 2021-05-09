import heapqueue
import strscans
import strutils
import tables

type Scheduler = ref object
  avail: HeapQueue[char]
  preds: Table[char, set[char]]
  succs: Table[char, set[char]]

proc parseSteps(input: string): Scheduler =
  var preds, succs: Table[char, set[char]]
  for line in input.splitLines:
    var one, two: string
    doAssert line.scanf("Step $w must be finished before step $w can begin.", one, two)
    let (a, b) = (one[0], two[0])
    preds.mgetOrPut(b, {}).incl(a)
    succs.mgetOrPut(a, {}).incl(b)
  var avail = initHeapQueue[char]()
  for c in succs.keys:
    if c notin preds:
      avail.push(c)
  Scheduler(avail: avail, preds: preds, succs: succs)

proc run(input: string, workers: int): (string, int) =
  var scheduler = input.parseSteps
  var done: set[char]
  var availWorkers = workers
  var workQueue: HeapQueue[(int, char)]

  proc sched(time = 0) =
    while scheduler.avail.len > 0 and availWorkers > 0:
      dec availWorkers
      let c = scheduler.avail.pop
      workQueue.push((time + c.ord - 4, c))

  sched()
  while workQueue.len > 0:
    let (time, curr) = workQueue.pop
    result[0] &= curr
    result[1] = time
    inc availWorkers
    done.incl(curr)
    for st in scheduler.succs.getOrDefault(curr, {}):
      if st notin done and scheduler.preds[st] <= done:
        scheduler.avail.push(st)
    sched(time)

proc part1*(input: string): string =
  input.run(1)[0]

proc part2*(input: string): int =
  input.run(5)[1]
