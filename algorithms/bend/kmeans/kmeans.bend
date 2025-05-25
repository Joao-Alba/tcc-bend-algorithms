object Point {features: List(f24), centroid_label: u24}
type PointTree:
  Nil
  Node {point: Point, ~left, ~right}
object FeaturesSum {features_sum: List(f24), count: u24}

def head_of(list: List(Point)) -> Point:
  match list:
    case List/Nil:
      return Point {features: [], centroid_label: 99999}
    case List/Cons:
      return list.head

def tail_of(list: List(Point)) -> List(Point):
  match list:
    case List/Nil:
      return List/Nil
    case List/Cons:
      return list.tail

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

def allocate_points(pointTree: PointTree, centroids: List(Point)) -> PointTree:
  match pointTree:
    case PointTree/Nil:
      return pointTree
    case PointTree/Node:
      point = pointTree.point
      open Point: point
      (closest_centroid_label, closest_centroid_distance) = find_closest(point, centroids)
      return PointTree/Node {point: Point {features: point.features,
                                           centroid_label: closest_centroid_label},
                             left: allocate_points(pointTree.left, centroids),
                             right: allocate_points(pointTree.right, centroids)}

def find_closest(point: Point, centroids: List(Point)) -> (u24, f24):
  match centroids:
    case List/Nil:
      return (9999999, 999999999.9)
    case List/Cons:
      centroid = centroids.head
      open Point: centroid
      distance = calc_distance(point, centroid)
      (next_closest_label, next_closest_distance) = find_closest(point, centroids.tail)
      return min(centroid.centroid_label, distance, next_closest_label, next_closest_distance)

def min(label1: u24, num1: f24, label2: u24, num2: f24) -> (u24, f24):
  if num1 <= num2:
    return (label1, num1)
  else:
    return (label2, num2)

def relocate_centroids(pointTree: PointTree, centroids: List(Point)) -> List(Point):
  sums_map = create_sums_map(pointTree, centroids)
  return apply_new_averages(sums_map, centroids)

def create_sums_map(pointTree: PointTree, centroids: List(Point)) -> Map(FeaturesSum):
  match pointTree:
    case PointTree/Nil:
      return Map/empty()
    case PointTree/Node:
      point = pointTree.point
      open Point: point
      current_sums_map = {point.centroid_label: FeaturesSum {features_sum: point.features, count: 1}}
      left_sums_map = create_sums_map(pointTree.left, centroids)
      right_sums_map = create_sums_map(pointTree.right, centroids)
      left_right = sum_maps(left_sums_map, right_sums_map, centroids)
      return sum_maps(left_right, current_sums_map, centroids)

def sum_maps(map1: Map(FeaturesSum), map2: Map(FeaturesSum), centroids: List(Point)) -> Map(FeaturesSum):
  match centroids:
    case List/Nil:
      return map1
    case List/Cons:
      centroid = centroids.head
      open Point: centroid
      (map1_contains, _) = Map/contains(map1, centroid.centroid_label)
      (map2_contains, _) = Map/contains(map2, centroid.centroid_label)
      if map2_contains:
        if map1_contains:
          features_sum1 = map1[centroid.centroid_label]
          open FeaturesSum: features_sum1
          features_sum2 = map2[centroid.centroid_label]
          open FeaturesSum: features_sum2
          map1[centroid.centroid_label] = FeaturesSum {features_sum: sum_lists(features_sum1.features_sum, features_sum2.features_sum),
                                                     count: (features_sum1.count + features_sum2.count)}
          return sum_maps(map1, map2, centroids.tail)
        else:
          features_sum2 = map2[centroid.centroid_label]
          open FeaturesSum: features_sum2
          map1[centroid.centroid_label] = features_sum2
          return sum_maps(map1, map2, centroids.tail)
      else:
        return sum_maps(map1, map2, centroids.tail)

def sum_lists(list1: List(f24), list2: List(f24)) -> List(f24):
  match list1:
    case List/Nil:
      return List/Nil
    case List/Cons:
      match list2:
        case List/Nil:
          return List/Nil
        case List/Cons:
          return List/Cons {head: (list1.head + list2.head), tail: sum_lists(list1.tail, list2.tail)}

def apply_new_averages(sums_map: Map(FeaturesSum), centroids: List(Point)) -> List(Point):
  (list_length, list) = List/length(centroids)
  bend result = List/Nil, count = 0, current = centroids:
    when count < list_length:
      match current:
        case List/Nil:
          return result
        case List/Cons:
          centroid = current.head
          open Point: centroid
          features_sum = sums_map[centroid.centroid_label]
          open FeaturesSum: features_sum
          new_values = divide_list_by_count(features_sum.features_sum, features_sum.count)
          return fork(List/Cons {head: Point {features: new_values,
                                              centroid_label: centroid.centroid_label},
                                 tail: result},
                      count + 1,
                      current.tail)
    else:
      return result

def divide_list_by_count(features: List(f24), count: u24) -> List(f24):
  match features:
    case List/Nil:
      return List/Nil
    case List/Cons:
      f_count = u24/to_f24(count)
      new_value = features.head / f_count
      return List/Cons {head: new_value, tail: divide_list_by_count(features.tail, count)}

def fit(point_tree: PointTree, centroids: List(Point), count: u24, max_count: u24) -> (PointTree, List(Point)):
  if count < max_count:
    new_point_tree = allocate_points(point_tree, centroids)
    new_centroids = relocate_centroids(new_point_tree, centroids)
    return fit(new_point_tree, new_centroids, count+1, max_count)
  else:
    return (point_tree, centroids)

def main():
  with IO:
    points <- generate_points("testA.txt")
    initial_centroids <- generate_points("centroidsA.txt")
    (points_length, _) = List/length(points)
    (point_tree, _) = tree_from_list(points, points_length)
    return time_process(point_tree, initial_centroids, 0, 5)




def time_process(points_test, initial_centroids, count, max_count):
  with IO:
    (start_high, start_low) <- IO/get_time()
    * <- IO/print("start: ")
    * <- IO/print(u24/to_string(start_high))
    * <- IO/print(", ")
    * <- IO/print(u24/to_string(start_low))
    (_, result) = fit(points_test, initial_centroids, count, max_count)
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

def tree_from_list(list: List(Point), size: u24) -> (PointTree, List(Point)):
  if size == 0:
    return (PointTree/Nil, list)
  else:
    left_size = size / 2
    (left_tree, remaining_after_left) = tree_from_list(list, left_size)

    root = head_of(remaining_after_left)
    remaining_after_root = tail_of(remaining_after_left)

    right_size = size - left_size - 1
    (right_tree, remaining_after_right) = tree_from_list(remaining_after_root, right_size)

    return (PointTree/Node {point: root, left: left_tree, right: right_tree}, remaining_after_right)

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
      return List/Cons {head: Point {features: build_features(features_split), centroid_label: label}, tail: build_point_list(list.tail)}

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