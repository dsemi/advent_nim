import json
import sequtils
import sugar

proc numbers(f: (JsonNode) -> bool, obj: JsonNode): BiggestInt =
  if f(obj):
    case obj.kind:
      of JObject:
        for (_, v) in obj.pairs:
          result += numbers(f, v)
      of JArray:
        for n in obj.items:
          result += numbers(f, n)
      of JInt:
        result += obj.getBiggestInt
      else:
        discard

proc part1*(input: string): BiggestInt =
  numbers((_) => true, parseJson(input))

proc part2*(input: string): BiggestInt =
  numbers((o) => o.kind != JObject or toSeq(o.pairs).allIt(it[1] != "red".newJString),
          parseJson(input))
