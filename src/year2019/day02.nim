import "intcode"

proc part1*(input: string): int =
  input.parse.runNoIo(12, 2)

proc part2*(input: string): int =
  let mem = input.parse
  for noun in 0..99:
    for verb in 0..99:
      if mem.runNoIo(noun, verb) == 19690720:
        return 100 * noun + verb
