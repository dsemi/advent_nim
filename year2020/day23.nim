import strutils
import sugar

proc read(input:string, arr: var openArray[int]) =
  var ns = collect(newSeq):
    for n in input:
      ($n).parseInt
  for n in 10 ..< arr.len:
    ns.add(n)
  arr[0] = ns[0]
  for i in 0 ..< ns.len:
    arr[ns[i]] = ns[(i+1) mod ns.len]

proc run(steps: int, d: var openArray[int]) =
  let m = d.high
  var curr = d[0]
  for _ in 1..steps:
    let a = d[curr]
    let b = d[a]
    let c = d[b]
    d[curr] = d[c]
    var n = if curr > 1: curr - 1 else: m
    while n == a or n == b or n == c:
      n = if n == 1: m else: n - 1
    d[c] = d[n]
    d[n] = a
    curr = d[curr]

proc part1*(input: string): string =
  var arr: array[10, int]
  read(input, arr)
  run(100, arr)
  var x = arr[1]
  while x != 1:
    result &= $x
    x = arr[x]

proc part2*(input: string): int =
  var arr: array[1_000_001, int]
  read(input, arr)
  run(10_000_000, arr)
  arr[1] * arr[arr[1]]
