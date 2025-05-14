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
          return pow((features_a.head - features_b.head), 2.0) + sum_diffs(features_a.tail, features_b.tail)

def pow(base: f24, exp: f24) -> f24:
  return base ** exp

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

def fit(point_tree: PointTree, centroids: List(Point), count: u24, max_count: u24) -> (PointTree, List(Point)):
  if count < max_count:
    new_point_tree = allocate_points(point_tree, centroids)
    new_centroids = relocate_centroids(new_point_tree, centroids)
    return fit(new_point_tree, new_centroids, count+1, max_count)
  else:
    return (point_tree, centroids)

def main() -> PointTree:
  #TODO: there is a bug if a centroid has no points related to it. The average calc breaks and returns *

  #TODO: start centroids correctly
  initial_centroids = [Point {features: [5.4, 3.7, 1.5, 0.2], centroid_label: 0},
                       Point {features: [4.4, 2.9, 1.4, 0.2], centroid_label: 1},
                       Point {features: [5.4, 3.4, 1.5, 0.4], centroid_label: 2}]

  points = generate_points()
  (points_length, _) = List/length(points)
  (pointTree, _) = tree_from_list(points, points_length)

  (new_point_tree, new_centroids) = fit(pointTree, initial_centroids, 0, 10)
  return new_point_tree

def generate_points() -> List(Point):
  return [Point {features: [5.1, 3.5, 1.4, 0.2], centroid_label: 9},
          Point {features: [4.9, 3.0, 1.4, 0.2], centroid_label: 9},
          Point {features: [4.7, 3.2, 1.3, 0.2], centroid_label: 9},
          Point {features: [4.6, 3.1, 1.5, 0.2], centroid_label: 9},
          Point {features: [5.0, 3.6, 1.4, 0.2], centroid_label: 9},
          Point {features: [5.4, 3.9, 1.7, 0.4], centroid_label: 9},
          Point {features: [4.6, 3.4, 1.4, 0.3], centroid_label: 9},
          Point {features: [5.0, 3.4, 1.5, 0.2], centroid_label: 9},
          Point {features: [4.4, 2.9, 1.4, 0.2], centroid_label: 9},
          Point {features: [4.9, 3.1, 1.5, 0.1], centroid_label: 9},
          Point {features: [5.4, 3.7, 1.5, 0.2], centroid_label: 9},
          Point {features: [4.8, 3.4, 1.6, 0.2], centroid_label: 9},
          Point {features: [4.8, 3.0, 1.4, 0.1], centroid_label: 9},
          Point {features: [4.3, 3.0, 1.1, 0.1], centroid_label: 9},
          Point {features: [5.8, 4.0, 1.2, 0.2], centroid_label: 9},
          Point {features: [5.7, 4.4, 1.5, 0.4], centroid_label: 9},
          Point {features: [5.4, 3.9, 1.3, 0.4], centroid_label: 9},
          Point {features: [5.1, 3.5, 1.4, 0.3], centroid_label: 9},
          Point {features: [5.7, 3.8, 1.7, 0.3], centroid_label: 9},
          Point {features: [5.1, 3.8, 1.5, 0.3], centroid_label: 9},
          Point {features: [5.4, 3.4, 1.7, 0.2], centroid_label: 9},
          Point {features: [5.1, 3.7, 1.5, 0.4], centroid_label: 9},
          Point {features: [4.6, 3.6, 1.0, 0.2], centroid_label: 9},
          Point {features: [5.1, 3.3, 1.7, 0.5], centroid_label: 9},
          Point {features: [4.8, 3.4, 1.9, 0.2], centroid_label: 9},
          Point {features: [5.0, 3.0, 1.6, 0.2], centroid_label: 9},
          Point {features: [5.0, 3.4, 1.6, 0.4], centroid_label: 9},
          Point {features: [5.2, 3.5, 1.5, 0.2], centroid_label: 9},
          Point {features: [5.2, 3.4, 1.4, 0.2], centroid_label: 9},
          Point {features: [4.7, 3.2, 1.6, 0.2], centroid_label: 9},
          Point {features: [4.8, 3.1, 1.6, 0.2], centroid_label: 9},
          Point {features: [5.4, 3.4, 1.5, 0.4], centroid_label: 9},
          Point {features: [5.2, 4.1, 1.5, 0.1], centroid_label: 9},
          Point {features: [5.5, 4.2, 1.4, 0.2], centroid_label: 9},
          Point {features: [4.9, 3.1, 1.5, 0.2], centroid_label: 9},
          Point {features: [5.0, 3.2, 1.2, 0.2], centroid_label: 9},
          Point {features: [5.5, 3.5, 1.3, 0.2], centroid_label: 9},
          Point {features: [4.9, 3.6, 1.4, 0.1], centroid_label: 9},
          Point {features: [4.4, 3.0, 1.3, 0.2], centroid_label: 9},
          Point {features: [5.1, 3.4, 1.5, 0.2], centroid_label: 9},
          Point {features: [5.0, 3.5, 1.3, 0.3], centroid_label: 9},
          Point {features: [4.5, 2.3, 1.3, 0.3], centroid_label: 9},
          Point {features: [4.4, 3.2, 1.3, 0.2], centroid_label: 9},
          Point {features: [5.0, 3.5, 1.6, 0.6], centroid_label: 9},
          Point {features: [5.1, 3.8, 1.9, 0.4], centroid_label: 9},
          Point {features: [4.8, 3.0, 1.4, 0.3], centroid_label: 9},
          Point {features: [5.1, 3.8, 1.6, 0.2], centroid_label: 9},
          Point {features: [4.6, 3.2, 1.4, 0.2], centroid_label: 9},
          Point {features: [5.3, 3.7, 1.5, 0.2], centroid_label: 9},
          Point {features: [5.0, 3.3, 1.4, 0.2], centroid_label: 9},
          Point {features: [7.0, 3.2, 4.7, 1.4], centroid_label: 9},
          Point {features: [6.4, 3.2, 4.5, 1.5], centroid_label: 9},
          Point {features: [6.9, 3.1, 4.9, 1.5], centroid_label: 9},
          Point {features: [5.5, 2.3, 4.0, 1.3], centroid_label: 9},
          Point {features: [6.5, 2.8, 4.6, 1.5], centroid_label: 9},
          Point {features: [5.7, 2.8, 4.5, 1.3], centroid_label: 9},
          Point {features: [6.3, 3.3, 4.7, 1.6], centroid_label: 9},
          Point {features: [4.9, 2.4, 3.3, 1.0], centroid_label: 9},
          Point {features: [6.6, 2.9, 4.6, 1.3], centroid_label: 9},
          Point {features: [5.2, 2.7, 3.9, 1.4], centroid_label: 9},
          Point {features: [5.0, 2.0, 3.5, 1.0], centroid_label: 9},
          Point {features: [5.9, 3.0, 4.2, 1.5], centroid_label: 9},
          Point {features: [6.0, 2.2, 4.0, 1.0], centroid_label: 9},
          Point {features: [6.1, 2.9, 4.7, 1.4], centroid_label: 9},
          Point {features: [5.6, 2.9, 3.6, 1.3], centroid_label: 9},
          Point {features: [6.7, 3.1, 4.4, 1.4], centroid_label: 9},
          Point {features: [5.6, 3.0, 4.5, 1.5], centroid_label: 9},
          Point {features: [5.8, 2.7, 4.1, 1.0], centroid_label: 9},
          Point {features: [6.2, 2.2, 4.5, 1.5], centroid_label: 9},
          Point {features: [5.6, 2.5, 3.9, 1.1], centroid_label: 9},
          Point {features: [5.9, 3.2, 4.8, 1.8], centroid_label: 9},
          Point {features: [6.1, 2.8, 4.0, 1.3], centroid_label: 9},
          Point {features: [6.3, 2.5, 4.9, 1.5], centroid_label: 9},
          Point {features: [6.1, 2.8, 4.7, 1.2], centroid_label: 9},
          Point {features: [6.4, 2.9, 4.3, 1.3], centroid_label: 9},
          Point {features: [6.6, 3.0, 4.4, 1.4], centroid_label: 9},
          Point {features: [6.8, 2.8, 4.8, 1.4], centroid_label: 9},
          Point {features: [6.7, 3.0, 5.0, 1.7], centroid_label: 9},
          Point {features: [6.0, 2.9, 4.5, 1.5], centroid_label: 9},
          Point {features: [5.7, 2.6, 3.5, 1.0], centroid_label: 9},
          Point {features: [5.5, 2.4, 3.8, 1.1], centroid_label: 9},
          Point {features: [5.5, 2.4, 3.7, 1.0], centroid_label: 9},
          Point {features: [5.8, 2.7, 3.9, 1.2], centroid_label: 9},
          Point {features: [6.0, 2.7, 5.1, 1.6], centroid_label: 9},
          Point {features: [5.4, 3.0, 4.5, 1.5], centroid_label: 9},
          Point {features: [6.0, 3.4, 4.5, 1.6], centroid_label: 9},
          Point {features: [6.7, 3.1, 4.7, 1.5], centroid_label: 9},
          Point {features: [6.3, 2.3, 4.4, 1.3], centroid_label: 9},
          Point {features: [5.6, 3.0, 4.1, 1.3], centroid_label: 9},
          Point {features: [5.5, 2.5, 4.0, 1.3], centroid_label: 9},
          Point {features: [5.5, 2.6, 4.4, 1.2], centroid_label: 9},
          Point {features: [6.1, 3.0, 4.6, 1.4], centroid_label: 9},
          Point {features: [5.8, 2.6, 4.0, 1.2], centroid_label: 9},
          Point {features: [5.0, 2.3, 3.3, 1.0], centroid_label: 9},
          Point {features: [5.6, 2.7, 4.2, 1.3], centroid_label: 9},
          Point {features: [5.7, 3.0, 4.2, 1.2], centroid_label: 9},
          Point {features: [5.7, 2.9, 4.2, 1.3], centroid_label: 9},
          Point {features: [6.2, 2.9, 4.3, 1.3], centroid_label: 9},
          Point {features: [5.1, 2.5, 3.0, 1.1], centroid_label: 9},
          Point {features: [5.7, 2.8, 4.1, 1.3], centroid_label: 9},
          Point {features: [6.3, 3.3, 6.0, 2.5], centroid_label: 9},
          Point {features: [5.8, 2.7, 5.1, 1.9], centroid_label: 9},
          Point {features: [7.1, 3.0, 5.9, 2.1], centroid_label: 9},
          Point {features: [6.3, 2.9, 5.6, 1.8], centroid_label: 9},
          Point {features: [6.5, 3.0, 5.8, 2.2], centroid_label: 9},
          Point {features: [7.6, 3.0, 6.6, 2.1], centroid_label: 9},
          Point {features: [4.9, 2.5, 4.5, 1.7], centroid_label: 9},
          Point {features: [7.3, 2.9, 6.3, 1.8], centroid_label: 9},
          Point {features: [6.7, 2.5, 5.8, 1.8], centroid_label: 9},
          Point {features: [7.2, 3.6, 6.1, 2.5], centroid_label: 9},
          Point {features: [6.5, 3.2, 5.1, 2.0], centroid_label: 9},
          Point {features: [6.4, 2.7, 5.3, 1.9], centroid_label: 9},
          Point {features: [6.8, 3.0, 5.5, 2.1], centroid_label: 9},
          Point {features: [5.7, 2.5, 5.0, 2.0], centroid_label: 9},
          Point {features: [5.8, 2.8, 5.1, 2.4], centroid_label: 9},
          Point {features: [6.4, 3.2, 5.3, 2.3], centroid_label: 9},
          Point {features: [6.5, 3.0, 5.5, 1.8], centroid_label: 9},
          Point {features: [7.7, 3.8, 6.7, 2.2], centroid_label: 9},
          Point {features: [7.7, 2.6, 6.9, 2.3], centroid_label: 9},
          Point {features: [6.0, 2.2, 5.0, 1.5], centroid_label: 9},
          Point {features: [6.9, 3.2, 5.7, 2.3], centroid_label: 9},
          Point {features: [5.6, 2.8, 4.9, 2.0], centroid_label: 9},
          Point {features: [7.7, 2.8, 6.7, 2.0], centroid_label: 9},
          Point {features: [6.3, 2.7, 4.9, 1.8], centroid_label: 9},
          Point {features: [6.7, 3.3, 5.7, 2.1], centroid_label: 9},
          Point {features: [7.2, 3.2, 6.0, 1.8], centroid_label: 9},
          Point {features: [6.2, 2.8, 4.8, 1.8], centroid_label: 9},
          Point {features: [6.1, 3.0, 4.9, 1.8], centroid_label: 9},
          Point {features: [6.4, 2.8, 5.6, 2.1], centroid_label: 9},
          Point {features: [7.2, 3.0, 5.8, 1.6], centroid_label: 9},
          Point {features: [7.4, 2.8, 6.1, 1.9], centroid_label: 9},
          Point {features: [7.9, 3.8, 6.4, 2.0], centroid_label: 9},
          Point {features: [6.4, 2.8, 5.6, 2.2], centroid_label: 9},
          Point {features: [6.3, 2.8, 5.1, 1.5], centroid_label: 9},
          Point {features: [6.1, 2.6, 5.6, 1.4], centroid_label: 9},
          Point {features: [7.7, 3.0, 6.1, 2.3], centroid_label: 9},
          Point {features: [6.3, 3.4, 5.6, 2.4], centroid_label: 9},
          Point {features: [6.4, 3.1, 5.5, 1.8], centroid_label: 9},
          Point {features: [6.0, 3.0, 4.8, 1.8], centroid_label: 9},
          Point {features: [6.9, 3.1, 5.4, 2.1], centroid_label: 9},
          Point {features: [6.7, 3.1, 5.6, 2.4], centroid_label: 9},
          Point {features: [6.9, 3.1, 5.1, 2.3], centroid_label: 9},
          Point {features: [5.8, 2.7, 5.1, 1.9], centroid_label: 9},
          Point {features: [6.8, 3.2, 5.9, 2.3], centroid_label: 9},
          Point {features: [6.7, 3.3, 5.7, 2.5], centroid_label: 9},
          Point {features: [6.7, 3.0, 5.2, 2.3], centroid_label: 9},
          Point {features: [6.3, 2.5, 5.0, 1.9], centroid_label: 9},
          Point {features: [6.5, 3.0, 5.2, 2.0], centroid_label: 9},
          Point {features: [6.2, 3.4, 5.4, 2.3], centroid_label: 9},
          Point {features: [5.9, 3.0, 5.1, 1.8], centroid_label: 9}]