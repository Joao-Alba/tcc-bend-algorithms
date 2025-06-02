from typing import List

class Point:
    def __init__(self, features: List[float], label: int):
        self.features = features
        self.label = label

    def __repr__(self):
        return f"Point {{features: {self.features}, centroid_label: {self.label}}}"


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


def write_points_as_functions(centroids: List[Point], test: List[Point], output_path: str):
    with open(output_path, 'w') as f:
        f.write("object Point {features: List(f24), centroid_label: u24}\n\n")

        f.write("def centroids():\n")
        f.write("  return [\n")
        for idx, point in enumerate(centroids):
            comma = "," if idx < len(centroids) - 1 else ""
            f.write(f"    {point}{comma}\n")
        f.write("  ]\n\n")

        f.write("def test():\n")
        f.write("  return [\n")
        for idx, point in enumerate(test):
            comma = "," if idx < len(test) - 1 else ""
            f.write(f"    {point}{comma}\n")
        f.write("  ]\n")

if __name__ == "__main__":
    centroids_input = '../../../datasets/kmeans/centroids.txt'
    test_input = '../../../datasets/kmeans/test.txt'
    output = '../../bend/kmeans/dataset.bend'

    centroids = read_points(centroids_input)
    test = read_points(test_input)

    write_points_as_functions(centroids, test, output)

    print(f"Saved both lists into {output}")
