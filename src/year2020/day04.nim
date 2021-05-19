import re
import sequtils
import strformat
import strutils

proc part1*(input: string): int =
  for line in input.split("\n\n"):
    if ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"].allIt(contains(line, re(fmt"(^|\s){it}:"))):
      inc result

proc part2*(input: string): int =
  for line in input.split("\n\n"):
    if [re"(^|\s)byr:(19[2-9][0-9]|200[0-2])(\s|$)",
        re"(^|\s)iyr:(201[0-9]|2020)(\s|$)",
        re"(^|\s)eyr:(202[0-9]|2030)(\s|$)",
        re"(^|\s)hgt:(1[5-8][0-9]|19[0-3])cm|hgt:(59|6[0-9]|7[0-6])in(\s|$)",
        re"(^|\s)hcl:#[0-9a-f]{6}(\s|$)",
        re"(^|\s)ecl:(amb|blu|brn|gry|grn|hzl|oth)(\s|$)",
        re"(^|\s)pid:[0-9]{9}(\s|$)"].allIt(contains(line, it)):
      inc result
