from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
import math

x, y = load_iris(return_X_y=True)

def predict(points_train, labels_train, points_test, k):
    results = []
    if is_list_of_lists(points_test):
        for point_test in points_test:
            results.append(predict_point(points_train, labels_train, point_test, k))
    else:
        results.append(predict_point(points_train, labels_train, points_test, k))
    return results

def predict_point(points_train, labels_train, points_test, k):
    neighbors = []
    for point_index, point_train in enumerate(points_train):
        distance = calc_distance(point_train, points_test)
        neighbors.append({'distance': distance, 'label': labels_train[point_index]})
    neighbors.sort(key=lambda neighbor: neighbor['distance'])
    neighbors = neighbors[:k]
    return get_majority(neighbors)

def calc_distance(point_a, point_b):
    difference_sum = 0
    for feature_index, feature in enumerate(point_a):
        difference_sum += (point_a[feature_index] - point_b[feature_index]) ** 2
    return math.sqrt(difference_sum)

def get_majority(neighbors):
    counts = {}
    for neighbor in neighbors:
        counts[neighbor] = counts.get(neighbor, 0) + 1
    return max(counts, key=counts.get)

def is_list_of_lists(var):
    return isinstance(var, list) and all(isinstance(i, list) for i in var)

x_train, x_test, y_train, y_test = train_test_split(x, y, test_size=0.1, random_state=42)
x_train = x_train.tolist(); x_test = x_test.tolist(); y_train = y_train.tolist(); y_test = y_test.tolist()

print(x_train)
print(y_train)
print(x_test)
print(y_test)
y_pred = predict(x_train, y_train, x_test, 5)
print(y_pred)