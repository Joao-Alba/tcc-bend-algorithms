object Point {features: List(f24), label: u24}
object MeasuredPoint {point: Point, distance: f24}

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
  #sort by distance
  first_k_distances = take_k_first(distances, k)
  #get majority of first_k_distances
  return 1

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
  points_train = [
    Point {features: [1.0, 5.2, 2.6], label: 2},
    Point {features: [5.1, 2.7, 7.6], label: 1}
  ]
  points_test = [
    Point {features: [6.1, 3.9, 3.3], label: 10},
    Point {features: [2.5, 8.2, 2.2], label: 10}
  ]
  return predict(points_train, points_test , 5)