import strutils

const PRIMES = [2, 3, 5, 7, 11, 13]

proc solve(goal, primeIndex: int): int =
  if primeIndex < 0:
    return goal
  let p = PRIMES[primeIndex]
  var pPower = 1
  var pSum = 1
  result = solve(goal, primeIndex - 1)
  while pSum < goal:
    pPower *= p
    pSum += pPower
    let subgoal = (goal + pSum - 1) div pSum
    result = min(result, pPower * solve(subgoal, primeIndex - 1))

proc part1*(input: string): int =
  let n = input.parseInt
  solve(n div 10, PRIMES.high)

proc part2*(input: string): int =
  let n = input.parseInt
  var arr = newSeq[int](1_000_000)
  for i in 1 .. arr.high:
    for j in countup(i, min(50*i, arr.high), i):
      arr[j] += 11*i
  for i, v in arr:
    if v >= n:
      return i
