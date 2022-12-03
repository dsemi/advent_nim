import fusion/matching
import sets
import strutils

proc parse(input: string): (seq[(string, string)], string) =
  [@reps, @molecule] := input.split("\n\n")
  var repss: seq[(string, string)]
  for rep in reps.splitlines:
    [@a, @b] := rep.split(" => ")
    repss.add((a, b))
  (repss, molecule)

proc allSingleReplacements(reps: seq[(string, string)], molecule: string): seq[string] =
  for (k, v) in reps:
    var begin = 0
    var index = molecule.find(k, begin)
    while index >= 0:
      result.add(molecule[0 ..< index] & v & molecule[index+k.len .. ^1])
      begin = index + 1
      index = molecule.find(k, begin)

proc part1*(input: string): int =
  let (reps, molecule) = parse(input)
  allSingleReplacements(reps, molecule).toHashSet.len

proc part2*(input: string): int =
  let mol = parse(input)[1]
  mol.count({'A'..'Z'}) - (mol.count("Rn") + mol.count("Ar")) - 2*mol.count("Y") - 1
