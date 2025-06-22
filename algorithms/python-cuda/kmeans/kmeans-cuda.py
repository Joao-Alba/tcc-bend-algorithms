import numpy as np
import cupy as cupy
from cuml.cluster import KMeans

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
    X_gpu = cupy.asarray(X_np)
    y_gpu = cupy.asarray(labels)

    return X_gpu, y_gpu

X_test, y_test = load_data('../../../datasets/kmeans/test.txt')
centroids, _ = load_data('../../../datasets/kmeans/centroids.txt')

kmeans = KMeans(
    n_clusters=centroids.shape[0],
    init=centroids,
    max_iter=10,
    tol=1e-12
)

start = cupy.cuda.Event()
end = cupy.cuda.Event()

start.record()

kmeans.fit(X_test)
predictions = kmeans.predict(X_test)

end.record()
end.synchronize()

gpu_time_ms = cupy.cuda.get_elapsed_time(start, end)
print(f"\nGPU compute time: {gpu_time_ms:.3f} ms\n")