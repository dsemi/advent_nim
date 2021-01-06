import strutils

proc makeSAT(input: string): array[1..300, array[1..300, int]] =
  let serialNum = input.parseInt
  var grid: array[1..300, array[1..300, int]]
  for y in grid.low..grid.high:
    for x in grid[y].low..grid[y].high:
      let rackId = x + 10
      var powerLevel = rackId * y
      powerLevel += serialNum
      powerLevel *= rackId
      powerLevel = powerLevel div 100 mod 10
      powerLevel -= 5
      grid[y][x] = powerLevel
  for y in countdown(grid.high, grid.low):
    for x in countdown(grid[y].high, grid[y].low):
      result[y][x] = grid[y][x]
      if y < grid.high:
        result[y][x] += result[y+1][x]
      if x < grid[y].high:
        result[y][x] += result[y][x+1]
      if y < grid.high and x < grid[y].high:
        result[y][x] -= result[y+1][x+1]

proc maxCell[T](size: int, sat: array[T, array[T, int]]): (int, int, int) =
  for y in sat.low..sat.high-size:
    for x in sat[y].low..sat[y].high-size:
      let cell = sat[y][x] - sat[y+size][x] - sat[y][x+size] + sat[y+size][x+size]
      if cell > result[2]:
        result = (x, y, cell)

proc part1*(input: string): (int, int) =
  let sat = makeSAT(input)
  let (x, y, _) = maxCell(3, sat)
  (x, y)

proc part2*(input: string): (int, int, int) =
  let sat = makeSAT(input)
  var max = 0
  for i in 1..299:
    let (x, y, cell) = maxCell(i, sat)
    if cell > max:
      max = cell
      result = (x, y, i)
