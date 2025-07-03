import matplotlib.pyplot as plt
import numpy as np

implementations = ['run-rs', 'run-c', 'python lib', 'python impl', 'python-cuda']

times = np.array([415.4233, 65.0567, 0.0360, 6.9168, 0.2669])

min_time = times.min()
normalized_times = times / min_time

sorted_indices = np.argsort(normalized_times)
implementations_sorted = [implementations[i] for i in sorted_indices]
normalized_sorted = normalized_times[sorted_indices]

plt.figure(figsize=(10, 6))
bars = plt.bar(implementations_sorted, normalized_sorted, color='mediumorchid')

for bar, norm_time in zip(bars, normalized_sorted):
    plt.text(bar.get_x() + bar.get_width() / 2,
             bar.get_height() * 1.1,
             f'{norm_time:.0f}x',
             ha='center', va='bottom', fontsize=9)

plt.ylabel('Multiplicador do tempo mínimo (log)')
plt.yscale('log')
plt.grid(True, axis='y', which='both', linestyle='--', alpha=0.6)

plt.tight_layout()
plt.savefig('knn_big.png', dpi=300)
plt.show()
