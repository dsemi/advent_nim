import sequtils
import strscans
import strutils

const tmpl = "Blueprint $i: Each ore robot costs $i ore. Each clay robot costs $i ore. Each obsidian robot costs $i ore and $i clay. Each geode robot costs $i ore and $i obsidian."

type
  Res = object
    ore: uint16
    clay: uint16
    obs: uint16
    geode: uint16

  Blueprint = ref object
    num: int
    oreCost: Res
    clayCost: Res
    obsCost: Res
    geodeCost: Res
    maxOre: uint16
    maxClay: uint16
    maxObs: uint16

const
  OreBot = Res(ore: 1)
  ClayBot = Res(clay: 1)
  ObsBot = Res(obs: 1)
  GeodeBot = Res(geode: 1)

func `<=`(a, b: Res): bool =
  a.ore <= b.ore and a.clay <= b.clay and a.obs <= b.obs and a.geode <= b.geode

func `+`(a, b: Res): Res =
  Res(ore: a.ore + b.ore, clay: a.clay + b.clay, obs: a.obs + b.obs, geode: a.geode + b.geode)

func `-`(a, b: Res): Res =
  Res(ore: a.ore - b.ore, clay: a.clay - b.clay, obs: a.obs - b.obs, geode: a.geode - b.geode)

func `+=`(a: var Res, b: Res) =
  a.ore += b.ore
  a.clay += b.clay
  a.obs += b.obs
  a.geode += b.geode

proc blueprints(input: string): seq[Blueprint] =
  for line in input.splitLines:
    var num, oreBotOre, clayBotOre, obsBotOre, obsBotClay, geodeBotOre, geodeBotObs: int
    doAssert line.scanf(tmpl, num, oreBotOre, clayBotOre, obsBotOre,
                        obsBotClay, geodeBotOre, geodeBotObs)
    result.add Blueprint(
      num: num,
      oreCost: Res(ore: uint16(oreBotOre)),
      clayCost: Res(ore: uint16(clayBotOre)),
      obsCost: Res(ore: uint16(obsBotOre), clay: uint16(obsBotClay)),
      geodeCost: Res(ore: uint16(geodeBotOre), obs: uint16(geodeBotObs)),
      maxOre: uint16(max([oreBotOre, clayBotOre, obsBotOre, geodeBotOre])),
      maxClay: uint16(obsBotClay),
      maxObs: uint16(geodeBotObs),
    )

proc upperBd(b: Blueprint, time: uint16, amts, bots: Res): uint16 =
  var amts = amts
  var bots = bots
  for i in 1'u16 .. time:
    amts.ore = b.maxOre
    if b.geodeCost <= amts:
      amts += bots - b.geodeCost
      bots += GeodeBot
    elif b.obsCost <= amts:
      amts += bots - b.obsCost
      bots += ObsBot
    else:
      amts += bots
    bots += ClayBot
  amts.geode

proc makeBot(b: Blueprint, mx: var uint16, time: uint16, amts, bots, newBot, cost: Res)

proc dfs(b: Blueprint, maxGeode: var uint16, time: uint16, amts, bots: Res) =
  maxGeode = max(maxGeode, amts.geode + time * bots.geode)
  if b.upperBd(time, amts, bots) <= maxGeode:
    return

  if bots.obs > 0 and time > 1:
    b.makeBot(maxGeode, time, amts, bots, GeodeBot, b.geodeCost)
  if bots.obs < b.maxObs and bots.clay > 0 and time > 3:
    b.makeBot(maxGeode, time, amts, bots, ObsBot, b.obsCost)
  if bots.ore < b.maxOre and time > 3:
    b.makeBot(maxGeode, time, amts, bots, OreBot, b.oreCost)
  if bots.clay < b.maxClay and time > 5:
    b.makeBot(maxGeode, time, amts, bots, ClayBot, b.clayCost)

proc makeBot(b: Blueprint, mx: var uint16, time: uint16, amts, bots, newBot, cost: Res) =
  var amts = amts
  for t in 1'u16 ..< time:
    if cost <= amts:
      b.dfs(mx, time - t, amts + bots - cost, bots + newBot)
      break
    amts += bots

proc sim(b: Blueprint, time: uint16): int =
  var res: uint16
  b.dfs(res, time, Res(), OreBot)
  res.int

proc part1*(input: string): int =
  for b in input.blueprints:
    result += b.num * b.sim(24)

proc part2*(input: string): int =
  result = 1
  for b in input.blueprints[0 ..< 3]:
    result *= b.sim(32)
