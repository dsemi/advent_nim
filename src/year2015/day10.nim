import sequtils

proc lookAndSay(s: string, n: int): int =
  var inp = s.toSeq
  var outp = newSeqOfCap[char](inp.len)
  for _ in 1..n:
    var curr = inp[0]
    var cnt = 0
    for c in inp:
      if curr == c:
        cnt += 1
      else:
        outp.add((cnt + '0'.ord).chr)
        outp.add(curr)
        curr = c
        cnt = 1
    outp.add((cnt + '0'.ord).chr)
    outp.add(curr)
    swap(inp, outp)
    outp.setLen(0)
  inp.len

proc part1*(input: string): int =
  input.lookAndSay(40)

proc part2*(input: string): int =
  input.lookAndSay(50)
