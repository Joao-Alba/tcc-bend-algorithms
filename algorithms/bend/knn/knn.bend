
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
  points_train = train()
  points_test = test()
  return predict(points_train, points_test, 5)

def test():
  return [
    Point {features: [4.11, -8.57, -3.51, -0.85, -1.9, 2.84, -4.05, -2.06, 2.1, -8.24], label: 2},
    Point {features: [4.48, -2.98, -6.26, 10.37, 10.3, 5.26, -4.5, -8.44, 4.82, -1.2], label: 3},
    Point {features: [0.83, -8.62, -4.29, -5.03, -1.09, 7.44, -4.87, 0.37, 3.43, -10.08], label: 2},
    Point {features: [-5.46, -1.56, -10.64, 5.06, -4.24, 1.93, -5.93, -0.33, 1.99, -4.04], label: 4},
    Point {features: [1.55, -6.51, -6.73, -3.74, -1.98, 5.53, -8.79, 1.47, 0.3, -8.12], label: 2},
    Point {features: [-8.79, -0.18, -8.45, 9.55, -5.65, 2.73, -6.09, 2.73, 3.57, -6.47], label: 4},
    Point {features: [-8.76, -0.35, -7.91, 6.88, -4.07, 4.78, -4.27, 0.7, 1.08, -6.91], label: 4}
  ]

def train():
  return [
    Point {features: [-6.99, 0.47, -8.23, 9.91, -3.22, 3.2, -4.68, 1.49, -0.45, -7.86], label: 4},
    Point {features: [2.39, -7.18, -11.34, 9.03, 7.33, 4.4, -7.29, -12.22, 3.97, -3.88], label: 3},
    Point {features: [-0.61, -6.14, -5.42, -2.48, -2.54, 6.43, -6.37, 0.25, 2.92, -8.71], label: 2},
    Point {features: [-4.93, 1.21, -10.17, 9.96, -3.33, 3.94, -4.54, 2.7, 0.14, -5.73], label: 4},
    Point {features: [-8.56, 8.27, 6.92, -3.08, -6.41, -5.62, -5.92, -0.22, -1.69, -2.52], label: 1},
    Point {features: [3.17, -8.88, -4.96, -2.26, -0.56, 6.31, -5.89, 0.59, 2.58, -8.36], label: 2},
    Point {features: [3.01, -4.17, -10.8, 9.7, 7.76, 5.37, -6.23, -8.68, 5.54, 0.58], label: 3},
    Point {features: [-11.68, 7.8, 4.72, -7.57, -7.08, -4.74, -2.99, 2.18, -2.28, -7.19], label: 1},
    Point {features: [3.13, -10.17, -8.03, 12.87, 8.91, 6.07, -4.89, -7.96, 5.7, -2.72], label: 3},
    Point {features: [1.8, -8.16, -8.44, 8.44, 11.72, 8.65, -3.35, -7.81, 2.57, -1.24], label: 3},
    Point {features: [4.88, -7.66, -10.0, 8.49, 9.2, 4.69, -4.04, -10.91, 6.18, -0.94], label: 3},
    Point {features: [0.48, -7.2, -10.11, 8.76, 8.68, 6.67, -4.3, -8.45, 1.4, -4.02], label: 3},
    Point {features: [-2.14, 6.49, 3.44, 0.77, -6.8, -4.68, -7.23, 6.78, 0.78, 1.82], label: 0}
  ]