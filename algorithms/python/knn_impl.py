import time
import math

def load_data(file_path):
    features = []
    labels = []

    with open(file_path, 'r') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            parts = line.split(';')
            feature_part = parts[0]
            label_part = parts[1] if len(parts) > 1 else None

            feature_values = list(map(float, feature_part.split(',')))
            features.append(feature_values)
            labels.append(int(label_part))

    return features, labels

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
        label = neighbor['label']
        counts[label] = counts.get(label, 0) + 1
    return max(counts, key=counts.get)

def is_list_of_lists(var):
    return isinstance(var, list) and all(isinstance(i, list) for i in var)

X_train, y_train = load_data('../../datasets/knn/train.txt')
X_test, y_test = load_data('../../datasets/knn/test.txt')

start = time.time()
y_pred = predict(X_train, y_train, X_test, 5)
end = time.time()
print('Time: ' + str(end-start))
print(y_pred)