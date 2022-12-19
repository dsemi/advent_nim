import bitops
import fusion/matching
import math
import nimsimd/avx2
import sequtils
import strutils

when defined(gcc) or defined(clang):
  {.localPassc: "-mavx2".}

const FactorA = 16807;
const FactorB = 48271;
let FactorA4 = mm256_set1_epi64x(984943658)
let FactorB4 = mm256_set1_epi64x(1914720637)
let Mod = mm256_set1_epi64x(0x7fffffff)
let Lower16 = mm256_set1_epi64x(0xffff)
let Zero = mm256_set1_epi64x(0)
let Three = mm256_set1_epi64x(3)
let Seven = mm256_set1_epi64x(7)

proc parse(input: string): (uint64, uint64) =
  [@a, @b] := input.splitLines.mapIt(it.splitWhitespace[^1].parseUInt.uint64)
  (a, b)

proc generate(x, factor: uint64): uint64 =
  result = x * factor
  result = (result shr 31) + (result and 0x7fffffff)
  result = ((result shr 31) + result) and 0x7fffffff

proc generate4(v, factor: M256i): M256i =
  result = mm256_mul_epu32(v, factor)
  let c = mm_set_epi32(0, 0, 0,31)
  result = mm256_add_epi64(mm256_srl_epi64(result, c), mm256_and_si256(result, Mod))
  result = mm256_and_si256(mm256_add_epi64(mm256_srl_epi64(result, c), result), Mod)

proc part1*(input: string): uint64 =
  let (a0, b0) = input.parse
  var aNs = [a0, 0, 0, 0]
  var bNs = [b0, 0, 0, 0]
  for i in 1..3:
    aNs[i] = generate(aNs[i-1], FactorA)
    bNs[i] = generate(bNs[i-1], FactorB)
  var a = mm256_setr_epi64x(aNs[0], aNs[1], aNs[2], aNs[3])
  var b = mm256_setr_epi64x(bNs[0], bNs[1], bNs[2], bNs[3])
  var res = Zero
  for _ in 1..10_000_000:
    res = mm256_sub_epi64(res, mm256_cmpeq_epi64(mm256_and_si256(a, Lower16),
                                                 mm256_and_si256(b, Lower16)))
    a = generate4(a, FactorA4)
    b = generate4(b, FactorB4)
  cast[array[4, uint64]](res).sum

proc doMask(v, c: M256i): int32 =
  mm256_movemask_pd(mm256_castsi256_pd(mm256_cmpeq_epi64(mm256_and_si256(v, c), Zero)))

proc part2*(input: string): int =
  let (a0, b0) = input.parse
  var aNs = [a0, 0, 0, 0]
  var bNs = [b0, 0, 0, 0]
  for i in 1..3:
    aNs[i] = generate(aNs[i-1], FactorA)
    bNs[i] = generate(bNs[i-1], FactorB)
  var a = mm256_setr_epi64x(aNs[0], aNs[1], aNs[2], aNs[3])
  var b = mm256_setr_epi64x(bNs[0], bNs[1], bNs[2], bNs[3])
  var maskA = doMask(a, Three)
  var maskB = doMask(b, Seven)
  for _ in 1..5_000_000:
    while maskA == 0:
      a = generate4(a, FactorA4)
      maskA = doMask(a, Three)
    while maskB == 0:
      b = generate4(b, FactorB4)
      maskB = doMask(b, Seven)
    let idxA = maskA.countTrailingZeroBits
    let idxB = maskB.countTrailingZeroBits
    maskA = maskA xor (1'i32 shl idxA)
    maskB = maskB xor (1'i32 shl idxB)
    if (cast[array[4, uint64]](a)[idxA] and 0xffff) == (cast[array[4, uint64]](b)[idxB] and 0xffff):
      inc result
