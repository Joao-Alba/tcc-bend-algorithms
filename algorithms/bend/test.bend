def main() -> (u24, u24):
  map = {0: 4, 1: 3, 2: 8, 3: 9}
  return find_majority(map, [0, 1, 2, 3])

def find_majority(labels_count: Map(u24), found_labels: List(u24)) -> (u24, u24):
  fold found_labels:
    case List/Nil:
      return (999, 0)
    case List/Cons:
      (next_label, next_count) = found_labels.tail()
      current_count = labels_count[found_labels.head]
      if next_count >= current_count:
        return (next_label, next_count)
      else:
        return (found_labels.head, current_count)