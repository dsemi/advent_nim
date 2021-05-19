import sequtils
import strutils

type Ip = object
  supernets: seq[string]
  hypernets: seq[string]

iterator ips(input: string): Ip =
  for line in input.splitlines:
    var ip = Ip(supernets: @[], hypernets: @[])
    for i, part in toSeq(line.split({'[', ']'})):
      if i mod 2 == 0:
        ip.supernets.add(part)
      else:
        ip.hypernets.add(part)
    yield ip

proc hasAbba(s: string): bool =
  for i in s.low..s.high-3:
    if s[i] != s[i+1] and s[i] == s[i+3] and s[i+1] == s[i+2]:
      return true

proc supportsTls(ip: Ip): bool =
  return ip.supernets.any(hasAbba) and not ip.hypernets.any(hasAbba)

proc part1*(input: string): int =
  for ip in ips(input):
    result += ip.supportsTls.int

iterator abas(s: string): (char, char) =
  for i in s.low..s.high-2:
    if s[i] != s[i+1] and s[i] == s[i+2]:
      yield (s[i], s[i+1])

proc supportsSsl(ip: Ip): bool =
  for supernet in ip.supernets:
    for (a, b) in abas(supernet):
      let bab = [b, a, b].join
      if ip.hypernets.anyIt(bab in it):
        return true

proc part2*(input: string): int =
  for ip in ips(input):
    result += ip.supportsSsl.int
