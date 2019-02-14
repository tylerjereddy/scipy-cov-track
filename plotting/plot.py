import numpy as np
import matplotlib
matplotlib.use('agg')
import matplotlib.pyplot as plt

print("numpy version:", np.__version__)
print("matplotlib version:", matplotlib.__version__)

version_data = []
python_cov_data = []
compiled_cov_data = []
with open('../results/scipy_historical_coverage.txt', 'r') as datafile:
    for line in datafile:
        if line.startswith('#') or line.startswith('\n'):
            continue
        else:
            scipy_version, python_cov, compiled_cov = line.split()
            scipy_version = scipy_version[1:]
            version_data.append(scipy_version)
            python_cov_data.append(int(python_cov))
            compiled_cov_data.append(int(compiled_cov))

# convert to arr and reverse data for
# ascending chronological order
versions = np.array(version_data)[::-1]
python_cov_data =  np.array(python_cov_data)[::-1]
compiled_cov_data =  np.array(compiled_cov_data)[::-1]

fig = plt.figure()
ax = fig.add_subplot(111)

ax.scatter(versions,
           python_cov_data,
           color='blue')

ax.plot(versions,
        python_cov_data,
        color='blue',
        label='Python')

ax.scatter(versions,
           compiled_cov_data,
           color='green')

ax.plot(versions,
        compiled_cov_data,
        color='green',
        label='compiled')

ax.set_xlabel('SciPy version')
ax.set_ylabel('% line coverage')
ax.legend()
fig.savefig('cov.png', dpi=300)
