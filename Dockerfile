# build Docker image in repo root
# with docker build -t scipy-cov .
FROM ubuntu:16.04

# aim for basic Python 2.7 / pip setup
# with SciPy repo clone
RUN \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y \
  cmake \
  gcc \
  gfortran \
  git \
  libcurl4-openssl-dev \
  libicu-dev \
  libopenblas-dev \
  liblapack-dev \
  libssl-dev \
  pkg-config \
  python-pip \
  ruby-dev \
  vim \
  zlib1g-dev && \
  git clone https://github.com/scipy/scipy.git && \
  pip install -U pip && \
  /usr/local/bin/pip install -U gcovr && \
  mkdir /container_output && \
  gem install github-linguist

# for exploring Python & compiled code line coverages retroactively
# over the history of the SciPy project, it is helpful to be able
# to specify various dependency versions on the command line
# with something like docker run -e CYTHON_VER=0.28.5 etc.
ENTRYPOINT \
  ["/bin/bash", "-c", \
   "/usr/local/bin/pip install cython==$CYTHON_VER numpy==$NUMPY_VER \
   pytest==$PYTEST_VER pytest-cov==$PYCOV_VER pytest-xdist==$XDIST_VER && \
   cd scipy && git checkout $SCIPY_HASH && \
   github-linguist --breakdown 2>&1 | tee /container_output/linguist_scipy_$SCIPY_HASH.txt && \
   if [[ \"$SCIPY_HASH\" = \"v1.0.0\" ]]; then python runtests.py --mode=full --gcov -- -n $TEST_CORES --cov-report term --cov=scipy 2>&1 | tee /container_output/runtests_cov_output_scipy_$SCIPY_HASH.txt; fi && \
   if [[ \"$SCIPY_HASH\" = \"v0.19.1\" ]]; then \
   /usr/local/bin/pip install nose==$NOSE_VER && \
   python runtests.py --mode=full --gcov -- --with-coverage --cover-package=scipy; fi && \
   if [[ \"$SCIPY_HASH\" = \"v0.18.1\" ]] || [[ \"$SCIPY_HASH\" = \"v0.17.1\" ]]; then \
   /usr/local/bin/pip install nose==$NOSE_VER && \
   python runtests.py --mode=full --gcov -- --with-coverage --cover-package=scipy --exclude='test_gzip_py3'; fi && \
   if [[ \"$SCIPY_HASH\" = \"v0.16.1\" ]] || [[ \"$SCIPY_HASH\" = \"v0.15.1\" ]] || [[ \"$SCIPY_HASH\" = \"v0.14.1\" ]]; then \
   /usr/local/bin/pip install nose==$NOSE_VER && \
   ln -sf /lib/x86_64-linux-gnu/libm-2.23.so /usr/lib/x86_64-linux-gnu/libm.so && \
   python runtests.py --mode=full --gcov -- --with-coverage --cover-package=scipy --exclude='test_gzip_py3'; fi && \
   if [[ \"$SCIPY_HASH\" = \"v0.13.3\" ]] || [[ \"$SCIPY_HASH\" = \"v0.12.1\" ]]; then \
   /usr/local/bin/pip install nose==$NOSE_VER && \
   git checkout v0.14.1 -- runtests.py && \
   ln -sf /lib/x86_64-linux-gnu/libm-2.23.so /usr/lib/x86_64-linux-gnu/libm.so && \
   python runtests.py --mode=full --gcov -- --with-coverage --cover-package=scipy --exclude='test_gzip_py3'; fi && \
   gcovr --version && \
   echo 'Compiled line coverage total:' && \
   gcovr -r . -s -o /container_output/gcovr_details_$SCIPY_HASH.txt -e '/scipy/build/*' -e 'scipy/fftpack/src/*' -e 'scipy/integrate/odepack/*' -e 'scipy/integrate/quadpack/*' -e 'scipy/interpolate/fitpack/*' -e 'scipy/linalg/src/id_dist/*' -e 'scipy/odr/odrpack/*' -e 'scipy/optimize/minpack/*' -e 'scipy/sparse/linalg/dsolve/SuperLU/*' -e 'scipy/sparse/linalg/eigen/arpack/*' -e 'scipy/spatial/qhull/src/*' -e 'scipy/special/amos/*' -e 'scipy/special/cdflib/*' -e 'scipy/spatial/_voronoi.c' -e 'scipy/spatial/_hausdorff.c' -e 'scipy/signal/_spectral.c' -e 'scipy/_lib/_ccallback_c.c' -e 'scipy/_lib/messagestream.c' -e 'scipy/stats/_stats.c' -e 'scipy/special/_ufuncs_cxx.cxx' -e 'scipy/special/_ufuncs.c'  -e 'scipy/special/_test_round.c' -e 'scipy/special/_ellip_harm_2.c' -e 'scipy/special/_comb.c'  -e 'scipy/special/cython_special.c' -e 'scipy/spatial/qhull.c' -e 'scipy/cluster/_hierarchy.c' -e 'scipy/cluster/_optimal_leaf_ordering.c' -e 'scipy/cluster/_vq.c' -e 'scipy/interpolate/interpnd.c' -e 'scipy/interpolate/_bspl.c' -e 'scipy/interpolate/_ppoly.c' -e 'scipy/io/matlab/mio5_utils.c' -e 'scipy/io/matlab/mio_utils.c' -e 'scipy/io/matlab/streams.c' -e 'scipy/linalg/cython_blas.c' -e 'scipy/linalg/cython_lapack.c' -e 'scipy/linalg/_decomp_update.c' -e 'scipy/linalg/_solve_toeplitz.c' -e 'scipy/ndimage/src/_cytest.c' -e 'scipy/ndimage/src/_ni_label.c' -e 'scipy/optimize/_group_columns.c' -e 'scipy/optimize/_lsq/givens_elimination.c' -e 'scipy/optimize/_trlib/_trlib.c' -e 'scipy/signal/_max_len_seq_inner.c' -e 'scipy/signal/_upfirdn_apply.c' -e 'scipy/sparse/csgraph/_min_spanning_tree.c' -e 'scipy/sparse/csgraph/_reordering.c' -e 'scipy/sparse/csgraph/_shortest_path.c' -e 'scipy/sparse/csgraph/_tools.c' -e 'scipy/sparse/csgraph/_traversal.c' -e 'scipy/sparse/_csparsetools.c' " \
  ]
