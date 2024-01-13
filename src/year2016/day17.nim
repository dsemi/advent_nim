import checksums/md5
import deques
import sequtils
import sets

import "../utils"

type Path = tuple
  pos: (int, int)
  str: string

proc isDone(path: Path): bool =
  path.pos == (4, 4)

proc neighbors(path: Path): iterator: Path =
  return iterator(): Path =
    if not path.isDone:
      for (c, d) in path.str.getMD5.zip("UDLR"):
        if c in "bcdef":
          let path2 = case d:
                        of 'U': (pos: path.pos + ( 0, -1), str: path.str & "U")
                        of 'D': (pos: path.pos + ( 0,  1), str: path.str & "D")
                        of 'L': (pos: path.pos + (-1 , 0), str: path.str & "L")
                        of 'R': (pos: path.pos + ( 1,  0), str: path.str & "R")
                        else: raiseAssert "Bad state"
          if path2.pos[0] > 0 and path2.pos[0] <= 4 and
             path2.pos[1] > 0 and path2.pos[1] <= 4:
            yield path2

proc part1*(input: string): string =
  for (_, path) in bfs(((1, 1), input), neighbors):
    if path.isDone:
      return path[1][input.len..^1]

proc part2*(input: string): int =
  result = int.low
  for (d, path) in bfs(((1, 1), input), neighbors):
    if path.isDone:
      result = max(result, d)
