import fusion/matching
import re
import options
import strutils
import sugar

type Marker = object
  dataLen: int
  repeat: int
  markerLen: int

let reg = re"\((\d+)x(\d+)\)"

proc parseMarker(input: string): Option[Marker] =
  var cap: array[2, string]
  let l = matchLen(input, reg, cap)
  if l >= 0:
    return some(Marker(dataLen: cap[0].parseInt,
                       repeat: cap[1].parseInt,
                       markerLen: l))

proc decompressedLength(f: (string) -> int, input: string): int =
  if input.len == 0:
    return 0
  if Some(@marker) ?= parseMarker(input):
    let
      totLen = marker.markerLen + marker.dataLen
      repeatedChars = input[marker.markerLen..<totLen]
    return marker.repeat * f(repeatedChars) + decompressedLength(f, input[totLen..^1])
  else:
    return 1 + decompressedLength(f, input[1..^1])


proc part1*(input: string): int =
  decompressedLength((a) => a.len, input)

proc part2*(input: string): int =
  decompressedLength((a) => part2(a), input)
