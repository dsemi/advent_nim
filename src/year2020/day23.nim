import sequtils
import strutils

proc read(input:string, arr: var openArray[uint32]) =
  var ns = input.mapIt(($it).parseUint.uint32)
  for n in 10.uint32 ..< arr.len.uint32:
    ns.add(n)
  arr[0] = ns[0]
  for i in 0 ..< ns.len:
    arr[ns[i]] = ns[(i+1) mod ns.len]

proc run(steps: int, d: var openArray[uint32]) =
  let m = d.high.uint32
  var curr = d[0]
  for _ in 1..steps:
    let a = d[curr]
    let b = d[a]
    let c = d[b]
    var n = curr
    while n == curr or n == a or n == b or n == c:
      n = if n == 1: m else: n - 1
    d[curr] = d[c]
    d[c] = d[n]
    d[n] = a
    curr = d[curr]

proc part1*(input: string): string =
  var arr: array[10, uint32]
  read(input, arr)
  run(100, arr)
  var x = arr[1]
  while x != 1:
    result &= $x
    x = arr[x]

proc part2*(input: string): uint64 =
  var arr: array[1_000_001, uint32]
  read(input, arr)
  run(10_000_000, arr)
  arr[1].uint64 * arr[arr[1]].uint64
