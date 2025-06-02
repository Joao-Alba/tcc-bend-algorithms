from typing import List


class Point:
    def __init__(self, features: List[float], label: int):
        self.features = {i: f for i, f in enumerate(features)}
        self.label = label

    def __repr__(self):
        features_str = ", ".join(f"{k}: {v}" for k, v in self.features.items())
        return f"Point {{features: {{{features_str}}}, label: {self.label}}}"


def read_points(file_path: str) -> List[Point]:
    result = []
    with open(file_path, 'r') as file:
        for line in file:
            line = line.strip()
            if not line:
                continue
            features_str, label_str = line.split(';')
            features = [float(f) for f in features_str.split(',')]
            label = int(label_str)
            result.append(Point(features, label))
    return result


def write_points_as_functions(train: List[Point], test: List[Point], output_path: str):
    with open(output_path, 'w') as f:
        f.write("object Point {features: Map(f24), label: u24}\n\n")

        f.write("def test():\n")
        f.write("  return [\n")
        for idx, point in enumerate(test):
            comma = "," if idx < len(test) - 1 else ""
            f.write(f"    {point}{comma}\n")
        f.write("  ]\n\n")

        f.write("def train():\n")
        f.write("  return [\n")
        for idx, point in enumerate(train):
            comma = "," if idx < len(train) - 1 else ""
            f.write(f"    {point}{comma}\n")
        f.write("  ]\n")


if __name__ == "__main__":
    train_input = '../../../datasets/decision_trees/train.txt'
    test_input = '../../../datasets/decision_trees/test.txt'
    output = '../../bend/decision_trees/dataset.bend'

    train = read_points(train_input)
    test = read_points(test_input)

    write_points_as_functions(train, test, output)

    print(f"Saved both lists into {output}")
