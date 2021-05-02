import "assembunny"

proc part1*(input: string): int =
  var prog = parseInstrs(input)
  prog.reg['a'] = 7
  prog.run
  prog.reg['a']

proc part2*(input: string): int =
  var prog = parseInstrs(input)
  prog.reg['a'] = 12
  prog.run
  prog.reg['a']
