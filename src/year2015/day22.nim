import fusion/matching
import sequtils
import strutils

import "../utils"

type
  Game = object
    playerHealth: int
    playerMana: int
    playerArmor: int
    bossHealth: int
    bossDamage: int
    shieldTurns: int
    poisonTurns: int
    rechargeTurns: int
    hard: bool
    spentMana: int

proc `<`(a, b: Game): bool =
  false

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

proc parseBoss(input: string, hard: bool): Game =
  [@bHealth, @bDamage] := input.splitlines.mapIt(it.split(": ")[^1].parseInt)
  Game(playerHealth: 50, playerMana: 500, bossHealth: bHealth, bossDamage: bDamage, hard: hard)

proc neighbors(s: Game): iterator(): (int, Game) =
  return iterator(): (int, Game) =
    var state = s
    if state.hard:
      state.playerHealth -= 1
      if state.playerHealth <= 0:
        return
    applyEffects(state)
    if state.bossHealth <= 0:
      yield (0, state)
      return
    for spell in spells:
      if state.playerMana >= spell.cost and not spell.active(state):
        var newState = state
        newState.playerMana -= spell.cost
        spell.effect(newState)
        applyEffects(newState)
        newState.playerHealth -= max(1, newState.bossDamage - newState.playerArmor)
        if newState.boss_health <= 0 or newState.playerHealth > 0:
          yield (spell.cost, newState)

proc minCostToWin(input: string, hard: bool): int =
  for (d, st) in dijkstra(parseBoss(input, hard), neighbors):
    if st.bossHealth <= 0:
      return d

proc part1*(input: string): int =
  minCostToWin(input, false)

proc part2*(input: string): int =
  minCostToWin(input, true)
