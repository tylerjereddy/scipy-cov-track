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

# write a second plot that also contains
# total line counts
python_tots = []
compiled_tots = []
with open('../results/total_lines.txt', 'r') as countfile:
    for line in countfile:
        if line.startswith('#'):
            continue
        else:
            version, python_tot, compiled_tot = line.split()
            python_tots.append(int(python_tot))
            compiled_tots.append(int(compiled_tot))

# convert to arr in ascending version order
python_tots =  np.array(python_tots)[::-1]
compiled_tots =  np.array(compiled_tots)[::-1]

ax2 = ax.twinx()

ax2.plot(versions,
        python_tots,
        color='blue',
        alpha=0.5,
        ls='dashed')

ax2.plot(versions,
        compiled_tots,
        color='green',
        alpha=0.5,
        ls='dashed')

ax2.set_ylabel('total lines (dashed / color matched)')
ax2.ticklabel_format(style='sci', axis='y', scilimits=(0,0))

fig.savefig('cov-tot.png', dpi=300)
