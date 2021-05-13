import algorithm
import hashes
import sequtils
import strutils
import tables

import "../utils"

const getDir = {
  '^': (-1,  0),
  '>': ( 0,  1),
  'v': ( 1,  0),
  '<': ( 0, -1),
}.toTable

type
  Turn = enum
    Left, Straight, Right

  Cart = object
    pos: Coord
    dir: Coord
    turn: Turn

proc turn(c: Coord, turn: Turn): Coord =
  let (y, x) = c
  case turn:
    of Left: (-x, y)
    of Straight: (y, x)
    of Right: (x, -y)

proc move(cart: var Cart, grid: seq[seq[char]]) =
  cart.pos += cart.dir
  let (r, c) = cart.pos
  case grid[r][c]:
    of '\\': cart.dir = (cart.dir[1], cart.dir[0])
    of '/': cart.dir = (-cart.dir[1], -cart.dir[0])
    of '+':
      cart.dir = cart.dir.turn(cart.turn)
      cart.turn = (if cart.turn == Turn.high: Turn.low else: cart.turn.succ)
    of '-', '|', '<', '>', 'v', '^': discard
    else: raiseAssert "Invalid position"

proc parseTracks(input: string): (seq[seq[char]], Table[Coord, Cart]) =
  for r, line in toSeq(input.splitLines):
    result[0].add(@[])
    for c, v in line:
      if v in "^>v<":
        result[1][(r, c)] = Cart(pos: (r, c), dir: getDir[v], turn: Left)
      result[0][r].add(v)

iterator tickAllCarts(grid: seq[seq[char]], carts: Table[Coord, Cart]): Coord =
  var carts = carts
  while carts.len > 1:
    var movedCarts: Table[Coord, Cart]
    let poss = toSeq(carts.keys).sorted
    for p in poss:
      var cart: Cart
      if carts.pop(p, cart):
        cart.move(grid)
        if cart.pos in movedCarts or cart.pos in carts:
          yield (cart.pos[1], cart.pos[0])
          movedCarts.del(cart.pos)
          carts.del(cart.pos)
        else:
          movedCarts[cart.pos] = cart
    carts = movedCarts
  for p in carts.keys:
    yield (p[1], p[0])

proc part1*(input: string): Coord =
  let (grid, carts) = input.parseTracks
  for pos in tickAllCarts(grid, carts):
    return pos

proc part2*(input: string): Coord =
  let (grid, carts) = input.parseTracks
  for pos in tickAllCarts(grid, carts):
    result = pos
