from ./ import dataset

object Point {features: List(f24), label: u24}
object MeasuredPoint {point: Point, distance: f24}
type LabelTree:
  Nil
  Node {label: u24, count: u24, ~left, ~right}


def powF(base: f24, exp: f24) -> f24:
  if exp == 0.0:
    return 1.0
  else:
    return base * powF(base, exp - 1.0)

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
  top_k = calc_distances_k(points_train, point, k)
  return get_majority(top_k)

def calc_distances_k(points_train: List(Point), point: Point, k: u24) -> List(MeasuredPoint):
  (list_length, list) = List/length(points_train)

  bend top_k = List/Nil, count = 0, current = points_train:
    when count < list_length:
      match current:
        case List/Nil:
          return top_k
        case List/Cons:
          new_distance = MeasuredPoint { point: current.head, distance: calc_distance(current.head, point) }
          top_k = insert_top_k(top_k, new_distance, k)
          return fork(top_k, count + 1, current.tail)
    else:
      return top_k

def insert_top_k(current_list: List(MeasuredPoint), new_item: MeasuredPoint, k: u24) -> List(MeasuredPoint):
  updated_list = insert_sorted(new_item, current_list)
  (length, _) = List/length(updated_list)
  if length > k:
    return remove_last(updated_list)
  else:
    return updated_list

def insert_sorted(new_point: MeasuredPoint, list: List(MeasuredPoint)) -> List(MeasuredPoint):
  match list:
    case List/Nil:
      return List/Cons(new_point, List/Nil)
    case List/Cons:
      open MeasuredPoint: new_point
      list_head = list.head
      open MeasuredPoint: list_head
      if list_head.distance > new_point.distance:
        return List/Cons(new_point, list)
      else:
        return List/Cons(list_head, insert_sorted(new_point, list.tail))

def remove_last(list):
  match list:
    case List/Nil:
      return List/Nil
    case List/Cons:
      match list.tail:
        case List/Nil:
          return List/Nil
        case List/Cons:
          return List/Cons(list.head, remove_last(list.tail))

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

def main():
  with IO:
    points_train = dataset/train()
    points_test = dataset/test()
    return time_process(points_train, points_test)


def time_process(points_train, points_test):
  with IO:
    * <- IO/print(points_train)
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