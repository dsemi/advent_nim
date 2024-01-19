import std/algorithm
import std/endians
import std/sequtils
import std/strutils

type Hand = enum
  HighCard, Pair, TwoPair, ThreeOfAKind,
  FullHouse, FourOfAKind, FiveOfAKind

proc addCard(h: var Hand, count: uint8) =
  case h
  of HighCard:
    if count == 2: h = Pair
  of Pair:
    if count == 2: h = TwoPair
    elif count == 3: h = ThreeOfAKind
  of TwoPair:
    if count == 3: h = FullHouse
  of ThreeOfAKind:
    if count == 2: h = FullHouse
    elif count == 4: h = FourOfAKind
  of FourOfAKind:
    if count == 5: h = FiveOfAKind
  else:
    raiseAssert "Invalid hand"

func val(j: uint8, a: char): uint8 =
  case a
  of 'T': 10
  of 'J': j
  of 'Q': 12
  of 'K': 13
  of 'A': 14
  else: uint8(a.ord - '0'.ord)

proc solve(input: string, j: uint8): uint64 =
  var hands = newSeq[uint64]()
  for line in input.splitLines:
    var cnt: array[15, uint8]
    var ord: array[8, uint8]
    var hand = HighCard
    for i, c in line[0 ..< 5]:
      let v = val(j, c)
      ord[i+1] = v
      cnt[v] += 1
      if v > 1:
        hand.addCard(cnt[v])
    let jokers = cnt[1]
    cnt[1] = 0
    let mostFreqCard = cnt.maxIndex
    for _ in 1'u8 .. jokers:
      cnt[mostFreqCard] += 1
      hand.addCard(cnt[mostFreqCard])
    ord[0] = uint8(hand)
    var value: uint64
    bigEndian64(addr value, addr ord)
    let bet = line[6..^1].parseInt.uint16
    hands.add value + bet
  hands.sort
  for i, hand in hands:
    result += (i.uint64 + 1) * (hand and uint16.high.uint64)

proc part1*(input: string): uint64 =
  input.solve(11)

proc part2*(input: string): uint64 =
  input.solve(1)
