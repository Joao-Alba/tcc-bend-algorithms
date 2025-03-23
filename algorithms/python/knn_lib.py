from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.neighbors import KNeighborsClassifier
from sklearn.metrics import accuracy_score

x, y = load_iris(return_X_y=True)

x_train, x_test, y_train, y_test = train_test_split(x, y, test_size=0.1, random_state=42)

knn = KNeighborsClassifier(n_neighbors=5)
knn.fit(x_train, y_train)

y_pred = knn.predict(x_test)
print(y_pred)
accuracy = accuracy_score(y_test, y_pred)

print(f"KNN Accuracy: {accuracy:.2f}")