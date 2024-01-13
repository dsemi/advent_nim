version     = "0.1.0"
author      = "Dan Seminara"
description = "Advent of Code problems implemented in Nim"
license     = "Unspecified"
srcDir      = "src"
bin         = @["main"]

requires "checksums >= 0.1"
requires "fusion >= 1.1"
requires "itertools >= 0.4.0"
requires "nim >= 1.6.6"
requires "nimsimd >= 1.2.2"
requires "parsetoml >= 0.6.0"

task test, "Runs the test suite":
  for i in 0..paramCount():
    echo paramStr(i)
  exec "nim c -r -d:release --threads:on tests/test.nim -- \"2015::\""
