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
          return pow((features_a.head - features_b.head), 2.0) + sum_diffs(features_a.tail, features_b.tail)

def pow(base: f24, exp: f24) -> f24:
  return base ** exp

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

def main() -> List(u24):
  points_train = generate_points_train()
  points_test = generate_points_test()
  return predict(points_train, points_test, 5)
  
def generate_points_train() -> List(Point):
  return [Point {features: [6.3, 3.3, 4.7, 1.6], label: 1},
          Point {features: [6.5, 3.0, 5.8, 2.2], label: 2},
          Point {features: [5.6, 2.5, 3.9, 1.1], label: 1},
          Point {features: [5.7, 2.8, 4.5, 1.3], label: 1},
          Point {features: [6.4, 2.8, 5.6, 2.2], label: 2},
          Point {features: [4.7, 3.2, 1.6, 0.2], label: 0},
          Point {features: [6.1, 3.0, 4.9, 1.8], label: 2},
          Point {features: [5.0, 3.4, 1.6, 0.4], label: 0},
          Point {features: [6.4, 2.8, 5.6, 2.1], label: 2},
          Point {features: [7.9, 3.8, 6.4, 2.0], label: 2},
          Point {features: [6.7, 3.0, 5.2, 2.3], label: 2},
          Point {features: [6.7, 2.5, 5.8, 1.8], label: 2},
          Point {features: [6.8, 3.2, 5.9, 2.3], label: 2},
          Point {features: [4.8, 3.0, 1.4, 0.3], label: 0},
          Point {features: [4.8, 3.1, 1.6, 0.2], label: 0},
          Point {features: [4.6, 3.6, 1.0, 0.2], label: 0},
          Point {features: [5.7, 4.4, 1.5, 0.4], label: 0},
          Point {features: [6.7, 3.1, 4.4, 1.4], label: 1},
          Point {features: [4.8, 3.4, 1.6, 0.2], label: 0},
          Point {features: [4.4, 3.2, 1.3, 0.2], label: 0},
          Point {features: [6.3, 2.5, 5.0, 1.9], label: 2},
          Point {features: [6.4, 3.2, 4.5, 1.5], label: 1},
          Point {features: [5.2, 3.5, 1.5, 0.2], label: 0},
          Point {features: [5.0, 3.6, 1.4, 0.2], label: 0},
          Point {features: [5.2, 4.1, 1.5, 0.1], label: 0},
          Point {features: [5.8, 2.7, 5.1, 1.9], label: 2},
          Point {features: [6.0, 3.4, 4.5, 1.6], label: 1},
          Point {features: [6.7, 3.1, 4.7, 1.5], label: 1},
          Point {features: [5.4, 3.9, 1.3, 0.4], label: 0},
          Point {features: [5.4, 3.7, 1.5, 0.2], label: 0},
          Point {features: [5.5, 2.4, 3.7, 1.0], label: 1},
          Point {features: [6.3, 2.8, 5.1, 1.5], label: 2},
          Point {features: [6.4, 3.1, 5.5, 1.8], label: 2},
          Point {features: [6.6, 3.0, 4.4, 1.4], label: 1},
          Point {features: [7.2, 3.6, 6.1, 2.5], label: 2},
          Point {features: [5.7, 2.9, 4.2, 1.3], label: 1},
          Point {features: [7.6, 3.0, 6.6, 2.1], label: 2},
          Point {features: [5.6, 3.0, 4.5, 1.5], label: 1},
          Point {features: [5.1, 3.5, 1.4, 0.2], label: 0},
          Point {features: [7.7, 2.8, 6.7, 2.0], label: 2},
          Point {features: [5.8, 2.7, 4.1, 1.0], label: 1},
          Point {features: [5.2, 3.4, 1.4, 0.2], label: 0},
          Point {features: [5.0, 3.5, 1.3, 0.3], label: 0},
          Point {features: [5.1, 3.8, 1.9, 0.4], label: 0},
          Point {features: [5.0, 2.0, 3.5, 1.0], label: 1},
          Point {features: [6.3, 2.7, 4.9, 1.8], label: 2},
          Point {features: [4.8, 3.4, 1.9, 0.2], label: 0},
          Point {features: [5.0, 3.0, 1.6, 0.2], label: 0},
          Point {features: [5.1, 3.3, 1.7, 0.5], label: 0},
          Point {features: [5.6, 2.7, 4.2, 1.3], label: 1},
          Point {features: [5.1, 3.4, 1.5, 0.2], label: 0},
          Point {features: [5.7, 3.0, 4.2, 1.2], label: 1},
          Point {features: [7.7, 3.8, 6.7, 2.2], label: 2},
          Point {features: [4.6, 3.2, 1.4, 0.2], label: 0},
          Point {features: [6.2, 2.9, 4.3, 1.3], label: 1},
          Point {features: [5.7, 2.5, 5.0, 2.0], label: 2},
          Point {features: [5.5, 4.2, 1.4, 0.2], label: 0},
          Point {features: [6.0, 3.0, 4.8, 1.8], label: 2},
          Point {features: [5.8, 2.7, 5.1, 1.9], label: 2},
          Point {features: [6.0, 2.2, 4.0, 1.0], label: 1},
          Point {features: [5.4, 3.0, 4.5, 1.5], label: 1},
          Point {features: [6.2, 3.4, 5.4, 2.3], label: 2},
          Point {features: [5.5, 2.3, 4.0, 1.3], label: 1},
          Point {features: [5.4, 3.9, 1.7, 0.4], label: 0},
          Point {features: [5.0, 2.3, 3.3, 1.0], label: 1},
          Point {features: [6.4, 2.7, 5.3, 1.9], label: 2},
          Point {features: [5.0, 3.3, 1.4, 0.2], label: 0},
          Point {features: [5.0, 3.2, 1.2, 0.2], label: 0},
          Point {features: [5.5, 2.4, 3.8, 1.1], label: 1},
          Point {features: [6.7, 3.0, 5.0, 1.7], label: 1},
          Point {features: [4.9, 3.1, 1.5, 0.2], label: 0},
          Point {features: [5.8, 2.8, 5.1, 2.4], label: 2},
          Point {features: [5.0, 3.4, 1.5, 0.2], label: 0},
          Point {features: [5.0, 3.5, 1.6, 0.6], label: 0},
          Point {features: [5.9, 3.2, 4.8, 1.8], label: 1},
          Point {features: [5.1, 2.5, 3.0, 1.1], label: 1},
          Point {features: [6.9, 3.2, 5.7, 2.3], label: 2},
          Point {features: [6.0, 2.7, 5.1, 1.6], label: 1},
          Point {features: [6.1, 2.6, 5.6, 1.4], label: 2},
          Point {features: [7.7, 3.0, 6.1, 2.3], label: 2},
          Point {features: [5.5, 2.5, 4.0, 1.3], label: 1},
          Point {features: [4.4, 2.9, 1.4, 0.2], label: 0},
          Point {features: [4.3, 3.0, 1.1, 0.1], label: 0},
          Point {features: [6.0, 2.2, 5.0, 1.5], label: 2},
          Point {features: [7.2, 3.2, 6.0, 1.8], label: 2},
          Point {features: [4.6, 3.1, 1.5, 0.2], label: 0},
          Point {features: [5.1, 3.5, 1.4, 0.3], label: 0},
          Point {features: [4.4, 3.0, 1.3, 0.2], label: 0},
          Point {features: [6.3, 2.5, 4.9, 1.5], label: 1},
          Point {features: [6.3, 3.4, 5.6, 2.4], label: 2},
          Point {features: [4.6, 3.4, 1.4, 0.3], label: 0},
          Point {features: [6.8, 3.0, 5.5, 2.1], label: 2},
          Point {features: [6.3, 3.3, 6.0, 2.5], label: 2},
          Point {features: [4.7, 3.2, 1.3, 0.2], label: 0},
          Point {features: [6.1, 2.9, 4.7, 1.4], label: 1},
          Point {features: [6.5, 2.8, 4.6, 1.5], label: 1},
          Point {features: [6.2, 2.8, 4.8, 1.8], label: 2},
          Point {features: [7.0, 3.2, 4.7, 1.4], label: 1},
          Point {features: [6.4, 3.2, 5.3, 2.3], label: 2},
          Point {features: [5.1, 3.8, 1.6, 0.2], label: 0},
          Point {features: [6.9, 3.1, 5.4, 2.1], label: 2},
          Point {features: [5.9, 3.0, 4.2, 1.5], label: 1},
          Point {features: [6.5, 3.0, 5.2, 2.0], label: 2},
          Point {features: [5.7, 2.6, 3.5, 1.0], label: 1},
          Point {features: [5.2, 2.7, 3.9, 1.4], label: 1},
          Point {features: [6.1, 3.0, 4.6, 1.4], label: 1},
          Point {features: [4.5, 2.3, 1.3, 0.3], label: 0},
          Point {features: [6.6, 2.9, 4.6, 1.3], label: 1},
          Point {features: [5.5, 2.6, 4.4, 1.2], label: 1},
          Point {features: [5.3, 3.7, 1.5, 0.2], label: 0},
          Point {features: [5.6, 3.0, 4.1, 1.3], label: 1},
          Point {features: [7.3, 2.9, 6.3, 1.8], label: 2},
          Point {features: [6.7, 3.3, 5.7, 2.1], label: 2},
          Point {features: [5.1, 3.7, 1.5, 0.4], label: 0},
          Point {features: [4.9, 2.4, 3.3, 1.0], label: 1},
          Point {features: [6.7, 3.3, 5.7, 2.5], label: 2},
          Point {features: [7.2, 3.0, 5.8, 1.6], label: 2},
          Point {features: [4.9, 3.6, 1.4, 0.1], label: 0},
          Point {features: [6.7, 3.1, 5.6, 2.4], label: 2},
          Point {features: [4.9, 3.0, 1.4, 0.2], label: 0},
          Point {features: [6.9, 3.1, 4.9, 1.5], label: 1},
          Point {features: [7.4, 2.8, 6.1, 1.9], label: 2},
          Point {features: [6.3, 2.9, 5.6, 1.8], label: 2},
          Point {features: [5.7, 2.8, 4.1, 1.3], label: 1},
          Point {features: [6.5, 3.0, 5.5, 1.8], label: 2},
          Point {features: [6.3, 2.3, 4.4, 1.3], label: 1},
          Point {features: [6.4, 2.9, 4.3, 1.3], label: 1},
          Point {features: [5.6, 2.8, 4.9, 2.0], label: 2},
          Point {features: [5.9, 3.0, 5.1, 1.8], label: 2},
          Point {features: [5.4, 3.4, 1.7, 0.2], label: 0},
          Point {features: [6.1, 2.8, 4.0, 1.3], label: 1},
          Point {features: [4.9, 2.5, 4.5, 1.7], label: 2},
          Point {features: [5.8, 4.0, 1.2, 0.2], label: 0},
          Point {features: [5.8, 2.6, 4.0, 1.2], label: 1},
          Point {features: [7.1, 3.0, 5.9, 2.1], label: 2}]

def generate_points_test() -> List(Point):
  return [Point {features: [6.1, 2.8, 4.7, 1.2], label: 1},
          Point {features: [5.7, 3.8, 1.7, 0.3], label: 0},
          Point {features: [7.7, 2.6, 6.9, 2.3], label: 2},
          Point {features: [6.0, 2.9, 4.5, 1.5], label: 1},
          Point {features: [6.8, 2.8, 4.8, 1.4], label: 1},
          Point {features: [5.4, 3.4, 1.5, 0.4], label: 0},
          Point {features: [5.6, 2.9, 3.6, 1.3], label: 1},
          Point {features: [6.9, 3.1, 5.1, 2.3], label: 2},
          Point {features: [6.2, 2.2, 4.5, 1.5], label: 1},
          Point {features: [5.8, 2.7, 3.9, 1.2], label: 1},
          Point {features: [6.5, 3.2, 5.1, 2.0], label: 2},
          Point {features: [4.8, 3.0, 1.4, 0.1], label: 0},
          Point {features: [5.5, 3.5, 1.3, 0.2], label: 0},
          Point {features: [4.9, 3.1, 1.5, 0.1], label: 0},
          Point {features: [5.1, 3.8, 1.5, 0.3], label: 0}]