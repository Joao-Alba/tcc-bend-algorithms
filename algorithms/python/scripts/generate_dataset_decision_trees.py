from sklearn.datasets import make_blobs
import random

n_samples = 100_000
n_features = 10
n_classes = 5
test_size = 100

output_train = 'train.txt'
output_test = 'test.txt'

X, y = make_blobs(
    n_samples=n_samples,
    n_features=n_features,
    centers=n_classes,
    cluster_std=1.5,
    random_state=42
)

data = list(zip(X, y))

random.seed(42)
random.shuffle(data)

test_data = data[:test_size]
train_data = data[test_size:]

def write_file(filename, dataset):
    with open(filename, 'w') as f:
        for features, label in dataset:
            features_str = ','.join(f'{value:.2f}' for value in features)
            line = f'{features_str};{label}\n'
            f.write(line)

write_file(output_train, train_data)
write_file(output_test, test_data)

print(f'Train dataset saved to {output_train} ({len(train_data)} rows)')
print(f'Test dataset saved to {output_test} ({len(test_data)} rows)')
