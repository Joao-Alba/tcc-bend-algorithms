
def main():
  return string_to_float("-1.576")

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