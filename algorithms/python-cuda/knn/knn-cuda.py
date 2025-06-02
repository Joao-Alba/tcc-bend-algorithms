import numpy as np
import cupy as cp
from cuml.neighbors import NearestNeighbors

file_path = 'data.txt'

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
        labels.append(label_part)

X_np = np.array(features, dtype=np.float32)
X_gpu = cp.asarray(X_np)

knn = NearestNeighbors(n_neighbors=5)

knn.fit(X_gpu)
knn.kneighbors(X_gpu)

start = cp.cuda.Event()
end = cp.cuda.Event()

start.record()

knn.fit(X_gpu)
distances, indices = knn.kneighbors(X_gpu)

end.record()
end.synchronize()

gpu_time_ms = cp.cuda.get_elapsed_time(start, end)

print(f"GPU compute time: {gpu_time_ms:.3f} ms")
