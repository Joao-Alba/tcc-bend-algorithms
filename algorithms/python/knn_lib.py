import time
from sklearn.neighbors import KNeighborsClassifier
from sklearn.metrics import accuracy_score
import numpy as np

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

X_train, y_train = load_data('../../datasets/knn/train.txt')
X_test, y_test = load_data('../../datasets/knn/test.txt')

knn = KNeighborsClassifier(n_neighbors=5)

start = time.time()

knn.fit(X_train, y_train)
y_pred = knn.predict(X_test)

end = time.time()

print('Time: ' + str(end-start))
print(y_pred)