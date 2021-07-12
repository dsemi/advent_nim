import deques
import heapqueue
import intsets
import sequtils
import strutils
import sugar
import tables

import "../utils"

type
  Edge = object
    dest: int
    doors: uint32
    keys: uint32
    len: int

  Maze = ref object
    grid: seq[char]
    cols: int
    moves: Table[int, seq[Edge]]

  State = ref object
    poss: seq[int]
    keys: uint32
    len: int

proc conv(c: char): uint32 =
  uint32(1 shl (c.ord - 'a'.ord))

proc parseMaze(input: string): Maze =
  var arr: seq[char]
  var cols: int
  for row in input.splitLines:
    cols = row.len
    arr.add(row)
  Maze(grid: arr, cols: cols)

proc availableMoves(maze: Maze, src: int): seq[Edge] =
  if src notin maze.moves:
    var moves: seq[Edge]
    var visited: IntSet
    var queue: Deque[Edge]
    queue.addLast(Edge(dest: src, doors: 0, keys: 0, len: 0))
    while queue.len > 0:
      let edge = queue.popFirst
      if edge.dest in visited:
        continue
      visited.incl(edge.dest)
      for p in [edge.dest - maze.cols, edge.dest - 1, edge.dest + 1, edge.dest + maze.cols]:
        if p != src and maze.grid[p] != '#':
          var edge = Edge(dest: p, doors: edge.doors, keys: edge.keys, len: edge.len + 1)
          let ch = maze.grid[p]
          case ch:
            of 'a'..'z':
              edge.keys = edge.keys or ch.conv
              moves.add(edge)
            of 'A'..'Z':
              edge.doors = edge.doors or ch.toLowerAscii.conv
            else:
              discard
          queue.addLast(edge)
    maze.moves[src] = moves
  maze.moves[src]

proc `<`(a, b: State): bool =
  a.len < b.len

proc search(maze: Maze, start: char): int =
  let startPoss = collect(newSeq):
    for i, v in maze.grid:
      if v == start:
        i
  let ks = maze.grid.filterIt(it.isLowerAscii).mapIt(it.conv).foldl(a or b)
  var queue: HeapQueue[State]
  var dists: Table[(seq[int], uint32), int]
  queue.push(State(poss: startPoss, keys: 0, len: 0))
  while queue.len > 0:
    let state = queue.pop
    if state.keys == ks:
      return state.len
    if state.len <= dists.getOrDefault((state.poss, state.keys), int.high):
      dists[(state.poss, state.keys)] = state.len
      for i, p in state.poss:
        for edge in maze.availableMoves(p):
          if (state.keys and edge.doors) == edge.doors and (state.keys and edge.keys) != edge.keys:
            var poss = state.poss
            poss[i] = edge.dest
            let keys = state.keys or edge.keys
            let len = state.len + edge.len
            if len < dists.getOrDefault((poss, keys), int.high):
              dists[(poss, keys)] = len
              queue.push(State(poss: poss, keys: keys, len: len))

proc part1*(input: string): int =
  input.parseMaze.search('@')

proc part2*(input: string): int =
  var maze = input.parseMaze
  for (k, v) in toSeq(countup((39, 39), (41, 41))).zip("@#@###@#@"):
    maze.grid[k[0] * maze.cols + k[1]] = v
  maze.search('@')
