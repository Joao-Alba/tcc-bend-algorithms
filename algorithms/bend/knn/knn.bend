object Point {features: List(f24), label: u24}
object MeasuredPoint {point: Point, distance: f24}
type LabelTree:
  Nil
  Node {label: u24, count: u24, ~left, ~right}

def sort(xs: List(MeasuredPoint)) -> List(MeasuredPoint):
  match xs:
    case List/Nil:
      return List/Nil
    case List/Cons:
      return insert(xs.head, sort(xs.tail))

def insert(v: MeasuredPoint, xs: List(MeasuredPoint)) -> List(MeasuredPoint):
  match xs:
    case List/Nil:
      return List/Cons(v, List/Nil)
    case List/Cons:
      return swap_gt(v, xs.head, xs.tail)

def swap_gt(v: MeasuredPoint, x: MeasuredPoint, xs: List(MeasuredPoint)) -> List(MeasuredPoint):
  open MeasuredPoint: v
  open MeasuredPoint: x
  if x.distance > v.distance:
    return List/Cons(v, List/Cons(x, xs))
  else:
    return List/Cons(x, insert(v, xs))

def calc_distance(point_a: Point, point_b: Point) -> f24:
  open Point: point_a
  open Point: point_b
  return Math/sqrt(sum_diffs(point_a.features, point_b.features))

def sum_diffs(features_a: List(f24), features_b: List(f24)) -> f24:
  match features_a:
    case List/Nil:
      return 0.0
    case List.Cons:
      match features_b:
        case List/Nil:
          return 0.0
        case List/Cons:
          return powF((features_a.head - features_b.head), 2.0) + sum_diffs(features_a.tail, features_b.tail)

def predict(points_train: List(Point), points_test: List(Point), k: u24) -> List(u24):
  match points_test:
    case List/Nil:
      return List/Nil
    case List/Cons:
      return List/Cons{head: predict_single(points_train, points_test.head, k),
                       tail: predict(points_train, points_test.tail, k)}

def predict_single(points_train: List(Point), point: Point, k: u24) -> u24:
  distances = calc_distances(points_train, point)
  sorted_distances = sort(distances)
  first_k_distances = take_k_first(sorted_distances, k)
  return get_majority(first_k_distances)

def get_majority(points: List(MeasuredPoint)) -> u24:
  label_tree = build_label_tree(points, LabelTree/Nil)
  (max_label, max_value) = find_max(label_tree)
  return max_label

def build_label_tree(points: List(MeasuredPoint), label_tree: LabelTree) -> LabelTree:
  match points:
    case List/Nil:
      return label_tree
    case List/Cons:
      open MeasuredPoint: points.head
      open Point: points.head.point
      return build_label_tree(points.tail, insert_label_into(label_tree, points.head.point.label))

def insert_label_into(label_tree: LabelTree, new_label: u24) -> LabelTree:
  match label_tree:
    case LabelTree/Nil:
      return LabelTree/Node {label: new_label, count: 1, left: LabelTree/Nil, right: LabelTree/Nil}
    case LabelTree/Node:
      if new_label == label_tree.label:
        return LabelTree/Node {label: label_tree.label, count: label_tree.count + 1, left: label_tree.left, right: label_tree.right}
      elif new_label < label_tree.label:
        return LabelTree/Node {label: label_tree.label, count: label_tree.count, left: insert_label_into(label_tree.left, new_label), right: label_tree.right}
      else:
        return LabelTree/Node {label: label_tree.label, count: label_tree.count, left: label_tree.left, right: insert_label_into(label_tree.right, new_label)}

def find_max(label_tree: LabelTree) -> (u24, u24):
  match label_tree:
    case LabelTree/Nil:
      return (0, 0)
    case LabelTree/Node:
      max_label_left, max_count_left = find_max(label_tree.left)
      max_label_right, max_count_right = find_max(label_tree.right)
      return max(label_tree.label, label_tree.count, max_label_left, max_count_left, max_label_right, max_count_right)

def max(label1: u24, num1: u24, label2: u24, num2: u24, label3: u24, num3: u24) -> (u24, u24):
  if num1 >= num2 & num1 >= num3:
    return (label1, num1)
  elif num2 >= num1 & num2 >= num3:
    return (label2, num2)
  else:
    return (label3, num3)

def calc_distances(points_train: List(Point), point: Point) -> List(MeasuredPoint):
  (list_length, list) = List/length(points_train)
  bend result = List/Nil, count = 0, current = points_train:
    when count < list_length:
      match current:
        case List/Nil:
          return result
        case List/Cons:
          return fork(List/Cons {head: MeasuredPoint
                                       {point: current.head, distance: calc_distance(current.head, point)},
                                 tail: result},
                      count + 1,
                      current.tail)
    else:
      return result

def take_k_first(points: List(MeasuredPoint), k: u24) -> List(MeasuredPoint):
  bend result = List/Nil, count = 0, current = points:
    when count < k:
      match current:
        case List/Cons:
          return fork(List/Cons { head: current.head, tail: result }, count + 1, current.tail)
        case List/Nil:
          return result
    else:
      return result

def main():
  with IO:
    points_train <- generate_points("train.txt")
    points_test <- generate_points("test.txt")
    return time_process(points_train, points_test)


def time_process(points_train, points_test):
  with IO:
    (start_high, start_low) <- IO/get_time()
    * <- IO/print("start: ")
    * <- IO/print(u24/to_string(start_high))
    * <- IO/print(", ")
    * <- IO/print(u24/to_string(start_low))
    result = predict(points_train, points_test, 5)
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

def generate_points(file_path):
  with IO:
    content <- IO/FS/read_file(file_path)
    match content:
      case Result/Ok:
        decoded_content = String/decode_utf8(content.val)
        lines = split_lines(decoded_content)
        return wrap(build_point_list(lines))
      case Result/Err:
        * <- IO/print("Error reading file\n")
        return List/Nil

def build_point_list(list: List(String)) -> List(Point):
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
      return List/Cons {head: Point {features: build_features(features_split), label: label}, tail: build_point_list(list.tail)}

def build_features(string_values: List(String)) -> List(f24):
  match string_values:
    case List/Nil:
      return List/Nil
    case List/Cons:
      return List/Cons {head: string_to_float(string_values.head), tail: build_features(string_values.tail)}

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
  (is_negative, positive_string) = remove_negative(string_value)
  dot_char = 46
  split = split_string(positive_string, dot_char)
  (raw_integer_part, raw_fraction_part) = first_two_from(split)
  integer_part = string_to_int(raw_integer_part)
  fraction_part = string_to_int(raw_fraction_part)
  length_fraction_part = string_length(raw_fraction_part)
  result_fraction_part = u24/to_f24(fraction_part) / powF(10.0, u24/to_f24(length_fraction_part))
  if is_negative:
    return 0.0 - (u24/to_f24(integer_part) + result_fraction_part)
  else:
    return u24/to_f24(integer_part) + result_fraction_part

def remove_negative(raw_string: String) -> (u24, String):
  minus_char = 45
  match raw_string:
    case String/Nil:
      return unreachable()
    case String/Cons:
      if raw_string.head == minus_char:
        return (1, raw_string.tail)
      else:
        return (0, raw_string)

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