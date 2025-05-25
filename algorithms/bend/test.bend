object Point {features: List(f24), label: u24}

def main():
  map = list_to_map([5.0, 3.5, 5.2], [0, 1, 2], Map/empty())
  return map[4]

def list_to_map(features_list: List(f24), features_indexes: List(u24), result: Map(f24)) -> Map(f24):
  match features_list:
    case List/Nil:
      return result
    case List/Cons:
      index = head_of(features_indexes)
      result[index] = features_list.head
      return list_to_map(features_list.tail, tail_of(features_indexes), result)

def tree_from_list(list: List(Point), size: u24) -> (Tree(Point), List(Point)):
  if size == 1:
    return (Tree/Leaf {value: head_of(list)}, tail_of(list))
  else:
    left_size = size / 2
    right_size = size - left_size

    (left_tree, rest_after_left) = tree_from_list(list, left_size)
    (right_tree, rest_after_right) = tree_from_list(rest_after_left, right_size)

    return (Tree/Node {left: left_tree, right: right_tree}, rest_after_right)

def head_of(list):
  match list:
    case List/Nil:
      return unreachable()
    case List/Cons:
      return list.head

def tail_of(list: List(Point)) -> List(Point):
  match list:
    case List/Nil:
      return List/Nil
    case List/Cons:
      return list.tail

def generate_points():
  return [Point {features: [5.1, 3.5, 1.4, 0.2], label: 9},
          Point {features: [4.9, 3.0, 1.4, 0.2], label: 9},
          Point {features: [4.7, 3.2, 1.3, 0.2], label: 9},
          Point {features: [4.6, 3.1, 1.5, 0.2], label: 9}]