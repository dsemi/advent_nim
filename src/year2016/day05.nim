import strutils
import md5

proc part1*(input: string): string =
  var
    arr: array[8, string]
    j = 0
  for i in countup(0, int.high):
    let h = (input & $i).toMD5
    if h[0] == 0 and h[1] == 0 and h[2] < 16:
      arr[j] = toHex(h[2], 1).toLowerAscii
      inc j
    if j == 8:
      return arr.join

proc part2*(input: string): string =
  var
    arr: array[8, string]
    j = 0
  for i in countup(0, int.high):
    let h = (input & $i).toMD5
    if h[0] == 0 and h[1] == 0 and h[2] < 8:
      let pos = h[2]
      if arr[pos] == "":
        arr[pos] = toHex(h[3], 2)[0..0].toLowerAscii
        inc j
    if j == 8:
      return arr.join
