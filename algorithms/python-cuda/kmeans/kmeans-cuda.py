import numpy as np
import cupy as cp
from cuml.cluster import KMeans

file_path = 'data.txt'

features = []
with open(file_path, 'r') as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        parts = line.split(';')
        feature_part = parts[0]
        feature_values = list(map(float, feature_part.split(',')))
        features.append(feature_values)

X_np = np.array(features, dtype=np.float32)
X_gpu = cp.asarray(X_np)


kmeans = KMeans(n_clusters=5, max_iter=300)

kmeans.fit(X_gpu)

start = cp.cuda.Event()
end = cp.cuda.Event()

start.record()

kmeans.fit(X_gpu)
labels = kmeans.labels_

end.record()
end.synchronize()

gpu_time_ms = cp.cuda.get_elapsed_time(start, end)

print(f"GPU compute time (KMeans): {gpu_time_ms:.3f} ms")
