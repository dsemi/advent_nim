import md5
import nimsimd/avx2
import threadpool

when defined(gcc) or defined(clang):
  {.localPassc: "-mavx2".}

const batchSize = 1000

proc hexify(d: sink MD5Digest, n: var M256i) =
  n = mm256_cvtepu8_epi16(cast[M128i](d))
  n = mm256_or_si256(mm256_sra_epi16(n, mm_setr_epi32(4, 0, 0, 0)),
                     mm256_and_si256(mm256_sll_epi16(n, mm_setr_epi32(8, 0, 0, 0)),
                                     mm256_set1_epi16(0xf00)))
  n = mm256_add_epi8(n, mm256_add_epi8(mm256_set1_epi8(48),
                                       mm256_and_si256(mm256_set1_epi8(39),
                                                       mm256_cmpgt_epi8(n, mm256_set1_epi8(9)))))

proc hashNum(seed: string, n: int, num: int): array[32, char] =
  var c: MD5Context
  var d: MD5Digest
  c.md5Init()
  c.md5Update(cstring(seed), len(seed))
  c.md5Update(cstring($n), len($n))
  c.md5Final(d)
  var n: M256i
  hexify(d, n)
  for _ in 1..num:
    c.md5Init()
    c.md5Update(cast[cstring](addr n), 32)
    c.md5Final(d)
    hexify(d, n)
  cast[array[32, char]](n)

proc idx(c: char): int =
  if c in '0'..'9':
    return int(c) - int('0')
  return int(c) - int('a') + 10

iterator findIndexes(seed: string, num: int = 0): int =
  var pot: array[16, seq[int]]
  for i1 in countup(0, int.high, batchSize):
    var arr = newSeq[FlowVar[array[32, char]]](batchSize)
    for i in 0 .. arr.high:
      arr[i] = spawn hashNum(seed, i+i1, num)
    for i in i1..<i1+batchSize:
      let hash = ^arr[i-i1]
      for j in hash.low..hash.high-4:
        if hash[j] == hash[j+1] and hash[j] == hash[j+2] and
           hash[j] == hash[j+3] and hash[j] == hash[j+4]:
          for v in pot[hash[j].idx]:
            if i - v <= 1000:
              yield v
          pot[hash[j].idx].setLen(0)
      for j in hash.low..hash.high-2:
        if hash[j] == hash[j+1] and hash[j] == hash[j+2]:
          pot[hash[j].idx].add(i)
          break

proc part1*(input: string): int =
  var c = 0
  for i in findIndexes(input):
    inc c
    if c == 64:
      return i

proc part2*(input: string): int =
  var c = 0
  for i in findIndexes(input, 2016):
    inc c
    if c == 64:
      return i
