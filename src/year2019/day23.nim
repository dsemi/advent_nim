import fusion/matching

import "intcode"

type
  Packet = object
    address: int
    x: int
    y: int

  SignalKind = enum
    ToNat, FromNat

  Signal = object
    kind: SignalKind
    v: int

iterator network(input: string): Signal =
  var computers: seq[Program]
  for i in 0..49:
    var prog = input.parse
    prog.send([i])
    computers.add(prog)
  var (x, y) = (0, 0)
  while true:
    var packets: seq[Packet]
    for comp in computers.mitems:
      comp.run
      if Some(@ns) ?= comp.recv(3):
        packets.add(Packet(address: ns[0], x: ns[1], y: ns[2]))
    if packets.len > 0:
      for packet in packets:
        if packet.address == 255:
          yield Signal(kind: ToNat, v: packet.y)
          (x, y) = (packet.x, packet.y)
        else:
          computers[packet.address].send([packet.x, packet.y])
    else:
      var allInp = true
      for comp in computers.mitems:
        comp.send([-1])
        comp.run
        allInp = allInp and not comp.hasOuts(3)
      if allInp:
        yield Signal(kind: FromNat, v: y)
        computers[0].send([x, y])

proc part1*(input: string): int =
  for s in input.network:
    if s.kind == ToNat:
      return s.v

proc part2*(input: string): int =
  for s in input.network:
    if s.kind == FromNat:
      if s.v == result:
        break
      result = s.v
