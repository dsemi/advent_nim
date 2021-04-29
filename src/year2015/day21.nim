import sequtils
import strutils
import unpack

type
  Item = object
    cost: int
    damage: int
    armor: int
  Player = object
    item: Item
    hp: int

const weaponShop = [
  Item(cost: 8, damage: 4, armor: 0), # Dagger
  Item(cost: 10, damage: 5, armor: 0), # Shortsword
  Item(cost: 25, damage: 6, armor: 0), # Warhammer
  Item(cost: 40, damage: 7, armor: 0), # Longsword
  Item(cost: 74, damage: 8, armor: 0), # Greataxe
]

const armorShop = [
  Item(cost: 13, damage: 0, armor: 1), # Leather
  Item(cost: 31, damage: 0, armor: 2), # Chainmail
  Item(cost: 53, damage: 0, armor: 3), # Splintmail
  Item(cost: 75, damage: 0, armor: 4), # Bandedmail
  Item(cost: 102, damage: 0, armor: 5), # Platemail
]

const ringShop = [
  Item(cost: 25, damage: 1, armor: 0), # Damage +1
  Item(cost: 50, damage: 2, armor: 0), # Damage +2
  Item(cost: 100, damage: 3, armor: 0), # Damage +3
  Item(cost: 20, damage: 0, armor: 1), # Defense +1
  Item(cost: 40, damage: 0, armor: 2), # Defense +2
  Item(cost: 80, damage: 0, armor: 3), # Defense +3
  Item(cost: 0, damage: 0, armor: 0), # None
]

proc `+`(a: Item, b: Item): Item =
  Item(cost: a.cost + b.cost,
       damage: a.damage + b.damage,
       armor: a.armor + b.armor)

iterator allEquipmentCombos(): Player =
  for weapon in weaponShop:
    for armor in armorShop:
      for i in ringShop.low..ringShop.high:
        for j in i+1..ringShop.high:
          for ring in [ringShop[i] + ringShop[j], ringShop[j]]:
            yield Player(item: weapon + armor + ring, hp: 100)

proc isWinning(b: Player, p: Player): bool =
  proc ttd(p1: Player, p2: Player): int =
    let q = p1.hp div max(1, p2.item.damage - p1.item.armor)
    let r = p1.hp mod max(1, p2.item.damage - p1.item.armor)
    if r == 0: q else: q + 1
  ttd(p, b) >= ttd(b, p)

proc parseBoss(s: string): Player =
  [hp, dmg, ar] <- s.splitlines.mapIt(it.split[^1].parseInt)
  Player(item: Item(cost: 0, damage: dmg, armor: ar), hp: hp)

iterator allBattles(input: string): (bool, Player) =
  let boss = parseBoss(input)
  for player in allEquipmentCombos():
    yield (isWinning(boss, player), player)

proc part1*(input: string): int =
  result = int.high
  for (won, player) in allBattles(input):
    if won:
      result = min(result, player.item.cost)

proc part2*(input: string): int =
  result = int.low
  for (won, player) in allBattles(input):
    if not won:
      result = max(result, player.item.cost)
