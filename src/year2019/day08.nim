import sequtils
import strutils
import tables

import "../ocr"
import "../utils"

proc part1*(input: string): int =
   let cnts = input.chunks(150).mapIt(it.toCountTable).foldl(if b['0'] < a['0']: b else: a)
   cnts['1'] * cnts['2']

proc part2*(input: string): string =
  let pts = input.chunks(150).transpose.mapIt(it.foldl(if a != '2': a else: b))
  pts.mapIt(if it == '0': ' ' else: '#').chunks(25).mapIt(it.join).join("\n").parseLetters
