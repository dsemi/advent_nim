proc increment(s: var string) =
  for i in countdown(s.high, s.low):
    if s[i] == 'z':
      s[i] = 'a'
    else:
      s[i] = (s[i].ord + 1).chr
      break

proc isValidPw(s: string): bool =
  result = false
  for i in s.low .. s.high - 2:
    if s[i].ord + 2 == s[i+1].ord + 1 and s[i+1].ord + 1 == s[i+2].ord:
      result = true
      break
  if not result:
    return false
  var cnt = 0
  var i = 0
  while i < s.high:
    if s[i] == s[i+1]:
      cnt += 1
      i += 1
    i += 1
  return cnt >= 2 and 'i' notin s and 'o' notin s and 'l' notin s

proc nextValidPw(start: string): string =
  result = start
  increment(result)
  while not isValidPw(result):
    increment(result)

proc part1*(input: string): string =
  nextValidPw(input)

proc part2*(input: string): string =
  nextValidPw(nextValidPw(input))
