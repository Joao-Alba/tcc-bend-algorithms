def main() -> u24:
  map = {1: 5}
  map[0] = 2
  (contains, map) = Map/contains(map, 0)
  return contains