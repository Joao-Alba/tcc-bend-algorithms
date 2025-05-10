type DecisionTree:
  Node {features_label: u24, threshold: f24, ~left, ~right}
  Leaf {prediction: u24}
object Point {features: Map(f24), label: u24}

def length_of(tree: Tree(T)) -> u24:
  fold tree:
    case Tree/Leaf:
      return 1
    case Tree/Node:
      return tree.left() + tree.right()

def find_best_split(point_tree: Tree(Point), every_feature_indexes: List(u24)) -> (f24, u24, f24):
  fold every_feature_indexes:
    case List/Nil:
      return (1.0, 9, 0.0)
    case List/Cons:
      (current_impurity, current_feature_index, current_threshold) = find_best_split_feature(point_tree, every_feature_indexes.head)
      (next_impurity, next_feature_index, next_threshold) = every_feature_indexes.tail()
      if current_impurity <= next_impurity:
        return (current_impurity, current_feature_index, current_threshold)
      else:
        return (next_impurity, next_feature_index, current_threshold)

def find_best_split_feature(point_tree: Tree(Point), feature_index: u24) -> (f24, u24, f24):
  fold point_tree:
    case Tree/Leaf:
      current_point = point_tree.value
      open Point: current_point
      (maybe_left_tree, maybe_right_tree) = split_points(point_tree, feature_index, current_point.features[feature_index])
      impurity = check_trees_weight(maybe_left_tree, maybe_right_tree)
      return (impurity, feature_index, current_point.features[feature_index])
    case Tree/Node:
      (left_impurity, left_feature_index, left_threshold) = point_tree.left()
      (right_impurity, right_feature_index, right_threshold) = point_tree.right()
      if left_impurity <= right_impurity:
        return (left_impurity, left_feature_index, left_threshold)
      else:
        return (right_impurity, right_feature_index, right_threshold)

def split_points(point_tree: Tree(Point), feature_index: u24, threshold: f24) -> (Maybe(Tree(Point)), Maybe(Tree(Point))):
  match point_tree:
    case Tree/Leaf:
      point = point_tree.value
      open Point: point
      if point.features[feature_index] <= threshold:
        return (Maybe/Some(point_tree), Maybe/None())
      else:
        return (Maybe/None(), Maybe/Some(point_tree))

    case Tree/Node:
      (left_left , left_right) = split_points(point_tree.left, feature_index, threshold)
      (right_left , right_right) = split_points(point_tree.right, feature_index, threshold)

      left_tree = match_existence(left_left, right_left)
      right_tree = match_existence(left_right, right_right)

      return (left_tree, right_tree)

def match_existence(a: Maybe(Tree(Point)), b: Maybe(Tree(Point))) -> Maybe(Tree(Point)):
  match a:
    case Maybe/Some:
      match b:
        case Maybe/Some:
          return Maybe/Some(![a.value, b.value])
        case Maybe/None:
          return a
    case Maybe/None:
      match b:
        case Maybe/Some:
          return b
        case Maybe/None:
          return Maybe/None()

def check_trees_weight(left_tree: Maybe(Tree(Point)), right_tree: Maybe(Tree(Point))) -> f24:
  match left_tree:
    case Maybe/Some:
      match right_tree:
        case Maybe/Some:
          left_length = u24/to_f24(length_of(left_tree.value))
          right_length = u24/to_f24(length_of(right_tree.value))
          left_weight = left_length / (left_length + right_length)
          right_weight = right_length / (left_length + right_length)
          return (calc_gini_impurity(left_tree.value) * left_weight) + (calc_gini_impurity(right_tree.value) * right_weight)
        case Maybe/None:
          return calc_gini_impurity(left_tree.value)
    case Maybe/None:
      match right_tree:
        case Maybe/Some:
          return calc_gini_impurity(right_tree.value)
        case Maybe/None:
          return unreachable()

def calc_gini_impurity(point_tree: Tree(Point)) -> f24:
  total = length_of(point_tree)
  (labels_count, found_labels) = create_labels_count(point_tree)
  (labels_num, _) = List/length(found_labels)

  impurity_sum = 0.0
  fold found_labels with impurity_sum:
    case List/Nil:
      return (1.0 - impurity_sum)
    case List/Cons:
      proportion = u24/to_f24(labels_count[found_labels.head]) / u24/to_f24(total)
      new_value = proportion ** 2.0
      return found_labels.tail((impurity_sum + new_value))

def create_labels_count(point_tree: Tree(Point)) -> (Map(u24), List(u24)):
  fold point_tree:
    case Tree/Leaf:
      point = point_tree.value
      open Point: point
      return ({point.label: 1}, [point.label])
    case Tree/Node:
      (map_left, keys_left) = point_tree.left()
      (map_right, keys_right) = point_tree.right()
      return merge_maps(map_left, keys_left, map_right, keys_right)

def merge_maps(map1: Map(u24), map1_keys: List(u24), map2: Map(u24), map2_keys: List(u24)) -> (Map(u24), List(u24)):
  fold map2_keys:
    case List/Nil:
      return (map1, map1_keys)
    case List/Cons:
      (map1_contains, _) = Map/contains(map1, map2_keys.head)
      if map1_contains:
        map1[map2_keys.head] = map1[map2_keys.head] + map2[map2_keys.head]
        map1_keys = add_to_set(map1_keys, map2_keys.head)
        return map2_keys.tail()
      else:
        map1[map2_keys.head] = map2[map2_keys.head]
        map1_keys = add_to_set(map1_keys, map2_keys.head)
        return map2_keys.tail()

def add_to_set(list: List(u24), value: u24) -> List(u24):
  match list:
    case List/Nil:
      return List/Cons {head: value, tail: List/Nil}
    case List/Cons:
      if list.head == value:
        return list
      else:
        return List/Cons {head: list.head, tail: add_to_set(list.tail, value)}

def main() -> f24:
  point_tree = generate_points()
  (impurity, feature_index, threshold) = find_best_split_feature(generate_points(), 2)
  return threshold

def generate_points() -> Tree(Point):
  return ![
  ![
    !Point{features: {0: 1.1, 1: 1.2, 2: 1.3, 3: 1.4}, label: 1},
    ![
      !Point{features: {0: 1.6, 1: 1.5, 2: 1.7, 3: 1.5}, label: 1},
      !Point{features: {0: 5.7, 1: 5.7, 2: 5.0, 3: 5.6}, label: 1}
	 ]
	],
  ![
    !Point{features: {0: 1.0, 1: 1.5, 2: 1.7, 3: 1.8}, label: 1},
    ![
      !Point{features: {0: 1.2, 1: 1.1, 2: 1.6, 3: 1.9}, label: 1},
      ![
        !Point{features: {0: 9.7, 1: 9.7, 2: 9.9, 3: 9.3}, label: 3},
        !Point{features: {0: 5.1, 1: 5.6, 2: 5.4, 3: 5.6}, label: 2}
	   ]
	 ]
   ]
  ]