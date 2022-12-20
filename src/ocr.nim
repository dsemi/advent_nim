import re
import sequtils
import tables
import strutils

const smallK = """
 ##  ###   ##  #### ####  ##  #  # ###   ## #  # #     ##  ###  ###   ### #  # #   # ####
#  # #  # #  # #    #    #  # #  #  #     # # #  #    #  # #  # #  # #    #  # #   #    #
#  # ###  #    ###  ###  #    ####  #     # ##   #    #  # #  # #  # #    #  #  # #    #.
#### #  # #    #    #    # ## #  #  #     # # #  #    #  # ###  ###   ##  #  #   #    # .
#  # #  # #  # #    #    #  # #  #  #  #  # # #  #    #  # #    # #     # #  #   #   #  .
#  # ###   ##  #### #     ### #  # ###  ##  #  # ####  ##  #    #  # ###   ##    #   ####
"""
const smallV = "ABCEFGHIJKLOPRSUYZ"

const largeK = """
  ##   #####   ####  ###### ######  ####  #    #    ### #    # #      #    # #####  #####  #    # ######
 #  #  #    # #    # #      #      #    # #    #     #  #   #  #      ##   # #    # #    # #    #      #
#    # #    # #      #      #      #      #    #     #  #  #   #      ##   # #    # #    #  #  #       #
#    # #    # #      #      #      #      #    #     #  # #    #      # #  # #    # #    #  #  #      #.
#    # #####  #      #####  #####  #      ######     #  ##     #      # #  # #####  #####    ##      # .
###### #    # #      #      #      #  ### #    #     #  ##     #      #  # # #      #  #     ##     #  .
#    # #    # #      #      #      #    # #    #     #  # #    #      #  # # #      #   #   #  #   #   .
#    # #    # #      #      #      #    # #    # #   #  #  #   #      #   ## #      #   #   #  #  #    .
#    # #    # #    # #      #      #   ## #    # #   #  #   #  #      #   ## #      #    # #    # #    .
#    # #####   ####  ###### #       ### # #    #  ###   #    # ###### #    # #      #    # #    # ######
"""
const largeV = "ABCEFGHJKLNPRXZ"

const specialK = """
      ##        ##        ##    #    #  ####
     #  #      #  #      #  #  # #  ##     #
     #  #  ##  #            #  # #   #    #.
     #### #  # #           #   # #   #    #.
     #  # #  # #  #       #    # #   #   # .
     #  #  ##   ##       ####   #   ###  # .
"""
const specialV = "AoC2017"

proc separateLetters(input: string, fill = '#'): seq[string] =
  let input = input.strip(chars = Newlines)
  let subs = [(re($fill), "#"), (re"[^\n]", " ")]
  let lns = input.splitLines
  proc anyFill(col: int): bool =
    for i in lns.low .. lns.high:
      if lns[i][col] == fill:
        return true
  var prevCol = 0
  for col in lns[0].low .. lns[0].len:
    if col != lns[0].len and anyFill(col):
      continue
    var rows = newSeq[string]()
    for row in lns:
      rows.add row[prevCol ..< col]
    let letter = rows.join("\n")
    prevCol = col+1
    if letter.contains({fill}):
      result.add letter.multiReplace(subs)

let
  smallLetters = separateLetters(smallK).zip(smallV).toTable
  largeLetters = separateLetters(largeK).zip(largeV).toTable
  specialLetters = separateLetters(specialK).zip(specialV).toTable

proc parseLetters*(input: string, fill = '#'): string =
  let letters = input.separateLetters(fill = fill)
  for letter in letters:
    if letter in smallLetters:
      result &= smallLetters[letter]
    elif letter in largeLetters:
      result &= largeLetters[letter]
    elif letter in specialLetters:
      result &= specialLetters[letter]
    else:
      raiseAssert "Failed to parse letter: " & letter
