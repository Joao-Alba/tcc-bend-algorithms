from sklearn.cluster import KMeans
from sklearn.datasets import load_iris

iris = load_iris()
X = iris.data
y = iris.target

kmeans = KMeans(n_clusters=3, random_state=42)
kmeans.fit(X)

y_pred = kmeans.predict(X)

print("Cluster centers:\n", kmeans.cluster_centers_)
print(y)
print("\nLabels predicted by K-Means:\n", y_pred)