version     = "0.1.0"
author      = "Dan Seminara"
description = "Advent of Code problems implemented in Nim"
license     = "Unspecified"
srcDir      = "src"
bin         = @["main"]

requires "fusion >= 1.1"
requires "nim >= 1.6.6"
requires "nimsimd >= 1.2.2"
requires "itertools >= 0.4.0"
requires "parsetoml >= 0.6.0"
requires "zerofunctional >= 1.2.1"

task test, "Runs the test suite":
  for i in 0..paramCount():
    echo paramStr(i)
  exec "nim c -r -d:release --threads:on tests/test.nim -- \"2015::\""
