import deques
import fusion/matching
import math
import options
import strutils
import sugar

{.experimental: "caseStmtMacros".}

type
  Sim = ref object
    reg: array['a'..'z', int]
    line: int
    instrs: seq[Instr]

  Instr = proc(reg: var Sim): bool

proc parseInstrs(input: string, send: proc(x: int), recv: proc(): Option[int]): seq[Instr] =
  for line in input.splitLines:
    let f = case line.splitWhitespace:
              of ["snd", @v]:
                capture v:
                  (proc(s: var Sim): bool =
                     let x = if v[0] in 'a'..'z': s.reg[v[0]] else: v.parseInt
                     send(x))
              of ["set", @r, @v]:
                capture r, v:
                  (proc(s: var Sim): bool =
                     let x = if v[0] in 'a'..'z': s.reg[v[0]] else: v.parseInt
                     s.reg[r[0]] = x)
              of ["add", @r, @v]:
                capture r, v:
                  (proc(s: var Sim): bool =
                     let x = if v[0] in 'a'..'z': s.reg[v[0]] else: v.parseInt
                     s.reg[r[0]] += x)
              of ["mul", @r, @v]:
                capture r, v:
                  (proc(s: var Sim): bool =
                     let x = if v[0] in 'a'..'z': s.reg[v[0]] else: v.parseInt
                     s.reg[r[0]] *= x)
              of ["mod", @r, @v]:
                capture r, v:
                  (proc(s: var Sim): bool =
                     let x = if v[0] in 'a'..'z': s.reg[v[0]] else: v.parseInt
                     s.reg[r[0]] = floorMod(s.reg[r[0]], x))
              of ["rcv", @r]:
                capture r:
                  (proc(s: var Sim): bool =
                     let x = recv()
                     if x.isNone:
                       return true
                     s.reg[r[0]] = x.get)
              of ["jgz", @a, @b]:
                capture a, b:
                  (proc(s: var Sim): bool =
                     let x = if a[0] in 'a'..'z': s.reg[a[0]] else: a.parseInt
                     let y = if b[0] in 'a'..'z': s.reg[b[0]] else: b.parseInt
                     if x > 0: s.line += y - 1)
              else: raiseAssert "Parse error: " & line
    result.add(f)

proc run(s: var Sim) =
  while s.line in s.instrs.low..s.instrs.high:
    let instr = s.instrs[s.line]
    if instr(s):
      break
    s.line += 1

proc part1*(input: string): int =
  var v = 0
  var s = Sim(instrs: input.parseInstrs(proc(x: int) = v = x,
                                        proc(): Option[int] =
                                          if v == 0:
                                            return some(v)))
  s.run
  return v

proc part2*(input: string): int =
  var q0: Deque[int]
  var q1: Deque[int]
  var s0 = Sim(instrs: input.parseInstrs(proc(x: int) = q0.addLast(x),
                                         proc(): Option[int] =
                                            if q1.len > 0:
                                              return some(q1.popFirst)))
  var p1Sends = 0
  var s1 = Sim(instrs: input.parseInstrs(proc(x: int) =
                                           inc p1Sends
                                           q1.addLast(x),
                                         proc(): Option[int] =
                                           if q0.len > 0:
                                             return some(q0.popFirst)))
  s1.reg['p'] = 1
  var firstRun = true
  while firstRun or q0.len > 0 or q1.len > 0:
    firstRun = false
    s0.run
    s1.run
  p1Sends
