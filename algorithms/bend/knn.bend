def calc_distance(point_a, point_b) -> f24:
  return Math/sqrt(sum_diffs(point_a, point_b))

def sum_diffs(point_a, point_b) -> f24:
  match point_a:
    case List/Nil:
      return 0.0
    case List.Cons:
      return pow((point_a.head - value_of(point_b)), 2.0) + sum_diffs(point_a.tail, tail_of(point_b))

def value_of(list) -> f24:
  match list:
    case List/Nil:
      return 0.0
    case List/Cons:
      return list.head

def tail_of(list):
  match list:
    case List/Nil:
      return List/Nil
    case List/Cons:
      return list.tail

def pow(base: f24, exp: f24) -> f24:
  return base ** exp

def main() -> f24:
  return calc_distance([1.0, 2.0, 3.0], [3.5, 1.2, 4.5])