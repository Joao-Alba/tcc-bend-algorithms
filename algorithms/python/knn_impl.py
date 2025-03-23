from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
import math

x, y = load_iris(return_X_y=True)

def predict(x_train, y_train, x_test_list, k):
    results = []
    if is_list_of_lists(x_test_list):
        for x_text in x_test_list:
            results.append(predict_single(x_train, y_train, x_text, k))
    else:
        results.append(predict_single(x_train, y_train, x_test_list, k))
    return results

def predict_single(x_train, y_train, x_test, k):
    objects = []
    for clazz, test_sample in enumerate(x_train):
        difference_sum = 0
        for feature_index, feature in enumerate(test_sample):
            difference_sum += (feature - x_test[feature_index]) ** 2
        distance = math.sqrt(difference_sum)
        objects.append({'distance': distance, 'clazz': y_train[clazz]})
    objects.sort(key=lambda obj: obj['distance'])
    objects = objects[:k]
    return count_majority(objects)

def count_majority(objects):
    counts = {}
    for obj in objects:
        clazz = obj['clazz']
        if clazz in counts:
            counts[clazz] += 1
        else:
            counts[clazz] = 1

    majority_category = None
    max_count = 0

    for category, count in counts.items():
        if count > max_count:
            max_count = count
            majority_category = category

    return majority_category

def is_list_of_lists(var):
    return isinstance(var, list) and all(isinstance(i, list) for i in var)

x_train, x_test, y_train, y_test = train_test_split(x, y, test_size=0.1, random_state=42)
x_train = x_train.tolist()
x_test = x_test.tolist()
y_train = y_train.tolist()
y_test = y_test.tolist()
y_pred = predict(x_train, y_train, x_test, 5)
print(y_pred)