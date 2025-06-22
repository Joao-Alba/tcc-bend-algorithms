import numpy as np
import time

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


def calc_gini_impurity(labels):
    counts = {}
    for label in labels:
        counts[label] = counts.get(label, 0) + 1

    total = len(labels)
    impurity_sum = 0
    for count in counts.values():
        proportion = count / total
        impurity_sum += proportion ** 2
    return 1 - impurity_sum

def fit(points, labels, max_depth):
    return grow_tree(points, labels, max_depth, 0)

def grow_tree(points, labels, max_depth, current_depth):
    if current_depth >= max_depth or len(set(labels)) == 1:
        return {'label': get_majority(labels)}

    best_feature, best_threshold = find_best_split(points, labels)

    left_points, left_labels, right_points, right_labels = split_dataset(points, labels, best_feature, best_threshold)

    left_branch = grow_tree(left_points, left_labels, max_depth, current_depth+1)
    right_branch = grow_tree(right_points, right_labels, max_depth, current_depth + 1)

    return {
        'feature_index': best_feature,
        'threshold': best_threshold,
        'left': left_branch,
        'right': right_branch
    }

def find_best_split(points, labels):
    best_feature, best_threshold, best_gini = None, None, float('inf')
    features_num = len(points[0])

    for feature_index in range(features_num):
        values = sorted(set(row[feature_index] for row in points))
        for threshold in values:
            left_points, left_labels, right_points, right_labels = split_dataset(points, labels, feature_index, threshold)

            left_weight = len(left_labels) / len(labels)
            right_weight = len(right_labels) / len(labels)
            gini = calc_gini_impurity(left_labels) * left_weight + calc_gini_impurity(right_labels) * right_weight

            if gini < best_gini:
                best_feature = feature_index
                best_threshold = threshold
                best_gini = gini

    return best_feature, best_threshold

def split_dataset(points, labels, feature_index, threshold):
    left_points, left_labels, right_points, right_labels = [], [], [], []

    for index, point in enumerate(points):
        if point[feature_index] <= threshold:
            left_points.append(point)
            left_labels.append(labels[index])
        else:
            right_points.append(point)
            right_labels.append(labels[index])

    return left_points, left_labels, right_points, right_labels


def get_majority(lst):
    counts = {}
    for label in lst:
        counts[label] = counts.get(label, 0) + 1
    return max(counts, key=counts.get)

def predict(tree, points):
    result = []
    for point in points:
        result.append(traverse(tree, point))
    return result

def traverse(node, point):
    if 'label' in node:
        return node['label']

    point_value = point[node['feature_index']]
    if point_value <= node['threshold']:
        return traverse(node['left'], point)
    else:
        return traverse(node['right'], point)

X_train, y_train = load_data('../../datasets/decision_trees/train.txt')
X_test, y_test = load_data('../../datasets/decision_trees/test.txt')

result_tree = fit(X_train, y_train, 10)
predicted = predict(result_tree, X_test)
print('Expected: ' + str(y_test))
print('Result: ' + str(predicted))
