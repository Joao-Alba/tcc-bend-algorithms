from ./ import dataset

type DecisionTree:
  Node {feature_index: u24, threshold: f24, ~left, ~right}
  Leaf {prediction: u24}
object Point {features: Map(f24), label: u24}


def grow_tree(point_tree: Tree(Point), every_feature_indexes: List(u24), max_depth: u24, current_depth: u24) -> DecisionTree:
  if current_depth >= max_depth | calc_gini_impurity(point_tree) == 0.0:
    (labels_count, found_labels) = create_labels_count(point_tree)
    (major_label, major_count) = find_majority(labels_count, found_labels)
    return DecisionTree/Leaf {prediction: major_label}
  else:
    (best_impurity, best_feature_index, best_threshold) = find_best_split(point_tree, every_feature_indexes)
    (maybe_left_tree, maybe_right_tree) = split_points(point_tree, best_feature_index, best_threshold)
    left_branch = grow_tree(Maybe/unwrap(maybe_left_tree), every_feature_indexes, max_depth, current_depth + 1)
    right_branch = grow_tree(Maybe/unwrap(maybe_right_tree), every_feature_indexes, max_depth, current_depth + 1)
    return DecisionTree/Node {feature_index: best_feature_index,
                              threshold: best_threshold,
                              left: left_branch,
                              right: right_branch}

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
        return (next_impurity, next_feature_index, next_threshold)

def find_best_split_feature(point_tree: Tree(Point), feature_index: u24) -> (f24, u24, f24):
  full_tree = point_tree
  fold point_tree:
    case Tree/Leaf:
      current_point = point_tree.value
      open Point: current_point
      (maybe_left_tree, maybe_right_tree) = split_points(full_tree, feature_index, current_point.features[feature_index])
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

def predict(test_point_tree: Tree(Point), decision_tree: DecisionTree) -> Tree(Point):
  fold test_point_tree:
    case Tree/Leaf:
      current_point = test_point_tree.value
      open Point: current_point
      return !Point {features: current_point.features, label: predict_single(current_point, decision_tree)}
    case Tree/Node:
      return ![test_point_tree.left(), test_point_tree.right()]

def predict_single(point: Point, decision_tree: DecisionTree) -> u24:
  fold decision_tree:
    case DecisionTree/Leaf:
      return decision_tree.prediction
    case DecisionTree/Node:
      open Point: point
      if point.features[decision_tree.feature_index] <= decision_tree.threshold:
        return decision_tree.left()
      else:
        return decision_tree.right()

def main():
  with IO:
    features_indexes = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    train_list = dataset/train()
    test_list = dataset/test()
    (train_length, _) = List/length(train_list)
    (train_tree, _) = tree_from_list(train_list, train_length)
    (test_length, _) = List/length(test_list)
    (test_tree, _) = tree_from_list(test_list, test_length)
    return time_process(train_tree, test_tree, features_indexes, 10, 0)


def time_process(train_tree, test_tree, features_indexes, max_depth, current_depth):
  with IO:
    (start_high, start_low) <- IO/get_time()
    * <- IO/print("start: ")
    * <- IO/print(u24/to_string(start_high))
    * <- IO/print(", ")
    * <- IO/print(u24/to_string(start_low))
    decision_tree = grow_tree(train_tree, features_indexes, max_depth, current_depth)
    result = predict(test_tree, decision_tree)
    * <- IO/print(result)
    (end_high, end_low) <- IO/get_time()
    * <- IO/print("\n")
    * <- IO/print("end: ")
    * <- IO/print(u24/to_string(end_high))
    * <- IO/print(", ")
    * <- IO/print(u24/to_string(end_low))
    * <- IO/print("\n")
    * <- IO/print("diff: ")
    * <- IO/print(u24/to_string((end_high - start_high)))
    * <- IO/print(", ")
    * <- IO/print(u24/to_string((end_low - start_low)))
    * <- IO/print("\n")
    return wrap(result)

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

def tail_of(list):
  match list:
    case List/Nil:
      return List/Nil
    case List/Cons:
      return list.tail