import "intcode"

proc part1*(input: string): int =
  var prog = input.parse
  prog[1] = 12
  prog[2] = 2
  prog.run
  prog[0]

proc part2*(input: string): int =
  let prog = input.parse
  for noun in 0..99:
    for verb in 0..99:
      var p = prog
      p[1] = noun
      p[2] = verb
      p.run
      if p[0] == 19690720:
        return 100 * noun + verb
