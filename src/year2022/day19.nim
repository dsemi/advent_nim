import nimsimd/sse41
import sequtils
import strscans
import strutils

when defined(gcc) or defined(clang):
  {.localPassc: "-msse4.1".}

const tmpl = "Blueprint $i: Each ore robot costs $i ore. Each clay robot costs $i ore. Each obsidian robot costs $i ore and $i clay. Each geode robot costs $i ore and $i obsidian."

type Blueprint = ref object
  num: int
  # 0 = geode, 1 = obsidian, 2 = clay , 3 = ore
  costs: array[4, M128i]
  maxCosts: M128i

proc blueprints(input: string): seq[Blueprint] =
  for line in input.splitLines:
    var b = Blueprint()
    var costs: array[4, array[4, int]]
    # 0 = geode, 1 = obsidian, 2 = clay , 3 = ore
    doAssert line.scanf(tmpl, b.num, costs[3][3], costs[2][3],
                        costs[1][3], costs[1][2],
                        costs[0][3], costs[0][1])
    for i, row in costs:
      b.costs[i] = mm_setr_epi32(costs[i][0].int32, costs[i][1].int32, costs[i][2].int32, costs[i][3].int32)
    b.maxCosts = b.costs.foldl(mm_max_epi32(a, b))
    result.add b

proc `|>=|`(a, b: M128i): bool = mm_movemask_epi8(mm_cmplt_epi32(a, b)) == 0

proc `|+|`(a, b: M128i): M128i = mm_add_epi32(a, b)

proc `|-|`(a, b: M128i): M128i = mm_sub_epi32(a, b)

proc `[]`(m: M128i, i: int): int32 = cast[array[4, int32]](m)[i]

proc sim(b: Blueprint, t: int): int32 =
  proc dfs(res: var int32, time: int, amts, bots: M128i, bans: uint8) =
    let geodes = amts[0]
    let geodeBots = bots[0]
    if time == 0:
      res = max(res, geodes)
      return
    var upperBd = geodes + time*geodeBots
    var (obs, obsRate, obsCost) = (amts[1], bots[1], b.costs[0][1])
    for t in countdown(time-1, 0):
      if obs >= obsCost:
        obs += obsRate - obsCost
        upperBd += t
      else:
        obs += obsRate
        obsRate += 1
    if upperBd <= res:
      return
    var bans = bans
    for i, costs in b.costs:
      if (bans and (1'u8 shl i)) == 0 and (i == 0 or bots[i] < b.maxCosts[i]) and amts |>=| costs:
        var chans = [0'i32, 0, 0, 0]
        chans[i] = 1
        let bots2 = mm_setr_epi32(chans[0], chans[1], chans[2], chans[3])
        res.dfs(time - 1, amts |+| bots |-| costs, bots |+| bots2, 0)
        bans = bans or (1'u8 shl i)
    res.dfs(time - 1, amts |+| bots, bots, bans)
  result.dfs(t, mm_setzero_si128(), mm_setr_epi32(0, 0, 0, 1), 0)

proc part1*(input: string): int =
  for b in input.blueprints:
    result += b.num * b.sim(24)

proc part2*(input: string): int =
  result = 1
  for b in input.blueprints[0 ..< 3]:
    result *= b.sim(32)
