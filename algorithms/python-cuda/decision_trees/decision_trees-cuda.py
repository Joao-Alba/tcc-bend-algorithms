import numpy as np
import cupy as cp
from cuml.tree import DecisionTreeClassifier

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
        labels.append(float(label_part))

X_np = np.array(features, dtype=np.float32)
y_np = np.array(labels, dtype=np.float32)

X_gpu = cp.asarray(X_np)
y_gpu = cp.asarray(y_np)

decision_tree = DecisionTreeClassifier(max_depth=10)

decision_tree.fit(X_gpu, y_gpu)

start = cp.cuda.Event()
end = cp.cuda.Event()

start.record()

decision_tree.fit(X_gpu, y_gpu)
predictions = decision_tree.predict(X_gpu)

end.record()
end.synchronize()

gpu_time_ms = cp.cuda.get_elapsed_time(start, end)

print(f"GPU compute time (Decision Tree): {gpu_time_ms:.3f} ms")
