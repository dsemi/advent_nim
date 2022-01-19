const LEN = 10_000_000

proc add1[T: SomeInteger](n: var T): T =
  result = n
  n += 1

proc lookAndSay(s: string, n: int): int =
  var inp = newSeq[byte](LEN)
  var outp = newSeq[byte](LEN)
  for i, c in s:
    inp[i] = byte(c.ord - '0'.ord)
  var iLen = s.len
  for _ in 1..n:
    var oLen = 0
    var c = 0
    while c < iLen:
      var l = 1
      while inp[c + l] == inp[c]:
        l += 1
      outp[oLen.add1] = byte(l)
      outp[oLen.add1] = inp[c]
      c += l
    swap(inp, outp)
    iLen = oLen
  iLen

proc part1*(input: string): int =
  input.lookAndSay(40)

proc part2*(input: string): int =
  input.lookAndSay(50)
