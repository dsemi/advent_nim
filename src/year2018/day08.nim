import deques
import math
import sequtils
import strutils
import sugar

import "../utils"

proc parseNodes(input: string): Tree[seq[int]] =
  var ns = input.splitWhitespace.map(parseInt).toDeque
  proc parseNode(): Tree[seq[int]] =
    let n = ns.popFirst
    let m = ns.popFirst
    let nodes = collect(newSeq):
      for _ in 1..n:
        parseNode()
    let vals = collect(newSeq):
      for _ in 1..m:
        ns.popFirst
    Tree[seq[int]](val: vals, children: nodes)
  parseNode()

proc part1*(input: string): int =
  input.parseNodes.map((v) => v.sum).sum

proc part2*(input: string): int =
  let tree = input.parseNodes
  var stack = @[tree]
  while stack.len > 0:
    let node = stack.pop
    if node.children.len == 0:
      result += node.val.sum
      continue
    for i in node.val:
      if i-1 in node.children.low..node.children.high:
        stack.add(node.children[i-1])
