from sklearn.datasets import make_blobs
import numpy as np

n_samples = 50
n_features = 10
n_clusters = 5
n_centroids = 5

output_data = '../../../datasets/kmeans/test.txt'
output_centroids = '../../../datasets/kmeans/centroids.txt'

X, _ = make_blobs(
    n_samples=n_samples,
    n_features=n_features,
    centers=n_clusters,
    cluster_std=1.5,
    random_state=42
)

with open(output_data, 'w') as file:
    for features in X:
        features_str = ','.join(f'{value:.2f}' for value in features)
        file.write(f'{features_str};9999\n')

print(f'Dataset saved to {output_data} ({n_samples} rows)')

centroid_indices = np.random.choice(X.shape[0], n_centroids, replace=False)
centroids = X[centroid_indices]

with open(output_centroids, 'w') as file:
    for label, features in enumerate(centroids):
        features_str = ','.join(f'{value:.2f}' for value in features)
        file.write(f'{features_str};{label}\n')

print(f'Centroids saved to {output_centroids} ({n_centroids} centroids)')
