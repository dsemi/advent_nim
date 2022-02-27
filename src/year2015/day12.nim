import json
import sequtils
import sugar

proc numbers(obj: JsonNode, f: (JsonNode) -> bool): BiggestInt =
  if f(obj):
    case obj.kind:
      of JObject:
        for (_, v) in obj.pairs:
          result += numbers(v, f)
      of JArray:
        for n in obj.items:
          result += numbers(n, f)
      of JInt:
        result += obj.getBiggestInt
      else:
        discard

proc part1*(input: string): BiggestInt =
  input.parseJson.numbers((_) => true)

proc part2*(input: string): BiggestInt =
  input.parseJson.numbers((o) => o.kind != JObject or o.pairs.toSeq.allIt(it[1] != "red".newJString))
