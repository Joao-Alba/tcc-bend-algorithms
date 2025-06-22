import random
import math
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


def predict(points, k, iterations):
    centroids = random.sample(points, k)
    initialize_points(points, centroids)
    for iteration in range(iterations):
        update_centroids(points, centroids)
        assign_points(points, centroids)
    return [point['cluster'] for point in points]

def update_centroids(points, centroids):
    clusters = separate_clusters(points, centroids)
    features_num = len(points[0]['features'])
    for cluster_index, cluster in enumerate(clusters):
        centroids[cluster_index] = get_features_average(cluster, features_num)

def get_features_average(cluster, features_num):
    features_sum = sum_features(features_num, cluster)
    features = [0 for _ in range(len(features_sum))]
    for feature_index, feature_sum in enumerate(features_sum):
        features[feature_index] = feature_sum / len(cluster)
    return features

def sum_features(features_num, cluster):
    result = [0 for _ in range(features_num)]
    for feature_index in range(features_num):
        for point in cluster:
            result[feature_index] += point['features'][feature_index]
    return result

def separate_clusters(points, centroids):
    clusters = [[] for _ in range(len(centroids))]
    for point in points:
        clusters[point['cluster']].append(point)
    return clusters

def assign_points(points, centroids):
    for point in points:
        point['cluster'] = find_closest(point, centroids)

def initialize_points(points, centroids):
    for index in range(len(points)):
        points[index] = {
            'features': points[index]
        }
        points[index]['cluster'] = find_closest(points[index], centroids)

def find_closest(point, centroids):
    centroid_distances = []
    for centroid, centroid_features in enumerate(centroids):
        centroid_distances.append({'distance': calc_distance(point['features'], centroid_features), 'cluster': centroid})
    centroid_distances.sort(key=lambda distance: distance['distance'])
    return centroid_distances[0]['cluster']

def calc_distance(point_a, point_b):
    difference_sum = 0
    for feature_index, feature in enumerate(point_a):
        difference_sum += (point_a[feature_index] - point_b[feature_index]) ** 2
    return math.sqrt(difference_sum)

X, _ = load_data('../../datasets/kmeans/test.txt')
centroids, _ = load_data('../../datasets/kmeans/centroids.txt')

start = time.time()

result = predict(X, len(centroids), 10)

end = time.time()

print("Time: " + str(end - start))
