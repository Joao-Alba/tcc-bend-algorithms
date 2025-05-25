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
        return (next_impurity, next_feature_index, current_threshold)

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
    features_indexes = [0, 1, 2, 3]
    train_tree <- generate_points("trainA.txt", features_indexes)
    test_tree <- generate_points("testA.txt", features_indexes)
    return time_process(train_tree, test_tree, features_indexes, 5, 0)

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

def generate_points(file_path: String, features_indexes: List(u24)):
  with IO:
    content <- IO/FS/read_file(file_path)
    match content:
      case Result/Ok:
        decoded_content = String/decode_utf8(content.val)
        lines = split_lines(decoded_content)
        point_list = build_point_list(lines, features_indexes)
        (list_length, _) = List/length(point_list)
        (point_tree, _) = tree_from_list(point_list, list_length)
        return wrap(point_tree)
      case Result/Err:
        * <- IO/print("Error reading file\n")
        return unreachable()

def tree_from_list(list: List(Point), size: u24) -> (Tree(Point), List(Point)):
  if size == 1:
    return (Tree/Leaf {value: head_of(list)}, tail_of(list))
  else:
    left_size = size / 2
    right_size = size - left_size

    (left_tree, rest_after_left) = tree_from_list(list, left_size)
    (right_tree, rest_after_right) = tree_from_list(rest_after_left, right_size)

    return (Tree/Node {left: left_tree, right: right_tree}, rest_after_right)

def build_point_list(list: List(String), features_indexes: List(u24)) -> List(Point):
  semicolon_char = 59
  comma_char = 44
  match list:
    case List/Nil:
      return List/Nil
    case List/Cons:
      fields = split_string(list.head, semicolon_char)
      (features_string, label_string) = first_two_from(fields)
      features_split = split_string(features_string, comma_char)
      label = string_to_int(label_string)
      features_list = build_features(features_split)
      features_map = list_to_map(features_list, features_indexes, Map/empty())
      return List/Cons {head: Point {features: features_map, label: label}, tail: build_point_list(list.tail, features_indexes)}

def build_features(string_values: List(String)) -> List(f24):
  match string_values:
    case List/Nil:
      return List/Nil
    case List/Cons:
      return List/Cons {head: string_to_float(string_values.head), tail: build_features(string_values.tail)}

def list_to_map(features_list: List(f24), features_indexes: List(u24), result: Map(f24)) -> Map(f24):
  match features_list:
    case List/Nil:
      return result
    case List/Cons:
      index = head_of(features_indexes)
      result[index] = features_list.head
      return list_to_map(features_list.tail, tail_of(features_indexes), result)

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

def split_string(string: String, delim: u24) -> List(String):
  split = String/split(string, delim)
  return reverse_all(split)

def reverse_all(list: List(String)) -> List(String):
  match list:
    case List/Nil:
      return List/Nil
    case List/Cons:
      return List/Cons {head: reverse_string(list.head), tail: reverse_all(list.tail)}

def reverse_string(raw: String) -> String:
  acc = ""
  fold raw with acc:
    case String/Nil:
      return acc
    case String/Cons:
      return raw.tail(String/Cons { head: raw.head, tail: acc })

def powU(base: u24, exp: u24) -> u24:
  if exp == 0:
    return 1
  else:
    return base * powU(base, exp - 1)

def powF(base: f24, exp: f24) -> f24:
  if exp == 0.0:
    return 1.0
  else:
    return base * powF(base, exp - 1.0)

def string_to_float(string_value: String) -> f24:
  dot_char = 46
  split = split_string(string_value, dot_char)
  (raw_integer_part, raw_fraction_part) = first_two_from(split)
  integer_part = string_to_int(raw_integer_part)
  fraction_part = string_to_int(raw_fraction_part)
  length_fraction_part = string_length(raw_fraction_part)
  result_fraction_part = u24/to_f24(fraction_part) / powF(10.0, u24/to_f24(length_fraction_part))
  return u24/to_f24(integer_part) + result_fraction_part

def string_to_int(string: String) -> u24:
  unit = string_length(string)
  fold string with unit:
    case String/Nil:
      return 0
    case String/Cons:
      return char_to_int(string.head) * powU(10, unit - 1) + string.tail(unit - 1)

def string_length(string: String) -> u24:
  match string:
    case String/Nil:
      return 0
    case String/Cons:
      return string_length(string.tail) + 1

def char_to_int(char: u24) -> u24:
  return char - 48

def first_two_from(list: List(String)) -> (String, String):
  match list:
    case List/Nil:
      return unreachable()
    case List/Cons:
      second = list.tail
      match second:
        case List/Nil:
          return unreachable()
        case List/Cons:
          return (list.head, second.head)

def split_lines(raw_string: String) -> List(String):
  new_line_char = 10
  first_split = split_string(raw_string, new_line_char)
  fold first_split:
    case List/Nil:
      return List/Nil
    case List/Cons:
      return List/Cons {head: clean_line(first_split.head), tail: first_split.tail}

def clean_line(line: String) -> String:
  carriage_return_char = 13
  match line:
    case String/Nil:
      return String/Nil
    case String/Cons:
      if line.head == carriage_return_char:
        return String/Nil
      else:
        return String/Cons {head: line.head, tail: clean_line(line.tail)}