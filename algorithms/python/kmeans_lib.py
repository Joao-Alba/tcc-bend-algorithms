from sklearn.cluster import KMeans
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

    X_np = np.array(features, dtype=np.float32)
    Y_np = np.array(labels, dtype=np.int64)

    return X_np, Y_np

X_train, _ = load_data('../../datasets/kmeans/test.txt')
centroids, _ = load_data('../../datasets/kmeans/centroids.txt')

kmeans = KMeans(
    n_clusters=centroids.shape[0],
    init=centroids,
    max_iter=10,
    tol=1e-12
)

start = time.time()
kmeans.fit(X_train)
y_pred = kmeans.predict(X_train)
end = time.time()

print('Time: ' + str(end - start))