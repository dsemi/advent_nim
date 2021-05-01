import "assembunny"

proc part1*(input: string): int =
  var prog = parseInstrs(input)
  prog.run
  prog.reg['a']

proc part2*(input: string): int =
  var prog = parseInstrs(input)
  prog.reg['c'] = 1
  prog.run
  prog.reg['a']
