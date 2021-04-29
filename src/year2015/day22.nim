import sequtils
import strutils
import unpack

type
  Game = object
    playerHealth: int
    playerMana: int
    playerArmor: int
    spentMana: int
    bossHealth: int
    bossDamage: int
    shieldTurns: int
    poisonTurns: int
    rechargeTurns: int

const
  magicMissile = (
    cost: 53,
    effect: proc(s: var Game) = s.bossHealth -= 4,
    active: proc(s: Game): bool = false
  )
  drain = (
    cost: 73,
    effect: proc(s: var Game) = s.bossHealth -= 2; s.playerHealth += 2,
    active: proc(s: Game): bool = false
  )
  shield = (
    cost: 113,
    effect: proc(s: var Game) = s.playerArmor += 7; s.shieldTurns = 6,
    active: proc(s: Game): bool = s.shieldTurns > 0
  )
  poison = (
    cost: 173,
    effect: proc(s: var Game) = s.poisonTurns = 6,
    active: proc(s: Game): bool = s.poisonTurns > 0
  )
  recharge = (
    cost: 229,
    effect: proc(s: var Game) = s.rechargeTurns = 5,
    active: proc(s: Game): bool = s.rechargeTurns > 0
  )
  spells = [magicMissile, drain, shield, poison, recharge]


proc applyEffects(state: var Game) =
  if state.shieldTurns > 0:
    if state.shieldTurns == 1:
      state.playerArmor -= 7
    state.shieldTurns -= 1
  if state.poisonTurns > 0:
    state.bossHealth -= 3
    state.poisonTurns -= 1
  if state.rechargeTurns > 0:
    state.playerMana += 101
    state.rechargeTurns -= 1

proc parseBoss(input: string): Game =
  [bHealth, bDamage] <- input.splitlines.mapIt(it.split(": ")[^1].parseInt)
  Game(playerHealth: 50, playerMana: 500, bossHealth: bHealth, bossDamage: bDamage)

proc minCostToWin(s: Game, hard: bool): int =
  var states = @[s]
  var state: Game
  result = int.high
  while states.len > 0:
    state = states.pop
    if hard:
      state.playerHealth -= 1
      if state.playerHealth <= 0:
         continue
    applyEffects(state)
    if state.bossHealth <= 0:
      result = min(result, state.spentMana)
      continue
    for spell in spells:
      if state.playerMana >= spell.cost and
         state.spentMana + spell.cost < result and
         not spell.active(state):
        var newState = state
        newState.playerMana -= spell.cost
        newState.spentMana += spell.cost
        spell.effect(newState)
        applyEffects(newState)
        if newState.bossHealth <= 0:
          result = newState.spentMana
          continue
        newState.playerHealth -= max(1, newState.bossDamage - newState.playerArmor)
        if newState.playerHealth > 0:
          states.add(newState)

proc part1*(input: string): int =
  minCostToWin(parseBoss(input), false)

proc part2*(input: string): int =
  minCostToWin(parseBoss(input), true)
