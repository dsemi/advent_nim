import re
import sequtils
import tables
import strutils
import zero_functional

const smallK = """
 ##  ###   ##  #### ####  ##  #  # ###   ## #  # #     ##  ###  ###   ### #  # #   # ####
#  # #  # #  # #    #    #  # #  #  #     # # #  #    #  # #  # #  # #    #  # #   #    #
#  # ###  #    ###  ###  #    ####  #     # ##   #    #  # #  # #  # #    #  #  # #    #.
#### #  # #    #    #    # ## #  #  #     # # #  #    #  # ###  ###   ##  #  #   #    #..
#  # #  # #  # #    #    #  # #  #  #  #  # # #  #    #  # #    # #     # #  #   #   #...
#  # ###   ##  #### #     ### #  # ###  ##  #  # ####  ##  #    #  # ###   ##    #   ####
"""
const smallV = "ABCEFGHIJKLOPRSUYZ"

const largeK = """
  ##   #####   ####  ###### ######  ####  #    #    ### #    # #      #    # #####  #####  #    # ######
 #  #  #    # #    # #      #      #    # #    #     #  #   #  #      ##   # #    # #    # #    #      #
#    # #    # #      #      #      #      #    #     #  #  #   #      ##   # #    # #    #  #  #       #
#    # #    # #      #      #      #      #    #     #  # #    #      # #  # #    # #    #  #  #      #.
#    # #####  #      #####  #####  #      ######     #  ##     #      # #  # #####  #####    ##      #..
###### #    # #      #      #      #  ### #    #     #  ##     #      #  # # #      #  #     ##     #...
#    # #    # #      #      #      #    # #    #     #  # #    #      #  # # #      #   #   #  #   #....
#    # #    # #      #      #      #    # #    # #   #  #  #   #      #   ## #      #   #   #  #  #.....
#    # #    # #    # #      #      #   ## #    # #   #  #   #  #      #   ## #      #    # #    # #.....
#    # #####   ####  ###### #       ### # #    #  ###   #    # ###### #    # #      #    # #    # ######
"""
const largeV = "ABCEFGHJKLNPRXZ"

proc separateLetters(input: string, fill = '#'): seq[string] =
  let input = input.strip(chars = Newlines)
  let subs = [(re($fill), "#"), (re"[^\n]", " ")]
  let lns = input.splitLines
  var prevCol = 0
  for col in lns[0].low .. lns[0].len:
    if col != lns[0].len and ((lns.low .. lns.high) --> exists(lns[it][col] == fill)):
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

proc parseLetters*(input: string, fill = '#', large = false): string =
  let letters = input.separateLetters(fill = fill)
  if large:
    for letter in letters:
      result &= largeLetters[letter]
  else:
    for letter in letters:
      result &= smallLetters[letter]
