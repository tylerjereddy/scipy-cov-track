# build Docker image in repo root
# with docker build -t scipy-cov .
FROM ubuntu:16.04

# aim for basic Python 2.7 / pip setup
# with SciPy repo clone
RUN \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y \
  gcc \
  gfortran \
  git \
  libopenblas-dev \
  liblapack-dev \
  python-pip \
  vim && \
  git clone https://github.com/scipy/scipy.git && \
  pip install -U pip && \
  /usr/local/bin/pip install gcovr

# for exploring Python & compiled code line coverages retroactively
# over the history of the SciPy project, it is helpful to be able
# to specify various dependency versions on the command line
# with something like docker run -e CYTHON_VER=0.28.5 etc.
ENTRYPOINT \
  ["/bin/bash", "-c", \
   "/usr/local/bin/pip install cython==$CYTHON_VER numpy==$NUMPY_VER \
   pytest==$PYTEST_VER pytest-cov==$PYCOV_VER pytest-xdist==$XDIST_VER && \
   cd scipy && git checkout $SCIPY_HASH && \
   if [[ \"$SCIPY_HASH\" = \"v1.0.0\" ]]; then python runtests.py --mode=full --gcov -- -n $TEST_CORES --cov-report term --cov=scipy; fi && \
   if [[ \"$SCIPY_HASH\" = \"v0.19.1\" ]] || [[ \"$SCIPY_HASH\" = \"v0.17.1\" ]]; then \
   /usr/local/bin/pip install nose==$NOSE_VER && \
   python runtests.py --mode=full --gcov -- --with-coverage --cover-package=scipy; fi && \
   if [[ \"$SCIPY_HASH\" = \"v0.18.1\" ]]; then \
   /usr/local/bin/pip install nose==$NOSE_VER && \
   python runtests.py --mode=full --gcov -- --with-coverage --cover-package=scipy --exclude='test_gzip_py3'; fi && \
   if [[ \"$SCIPY_HASH\" = \"v0.16.1\" ]] || [[ \"$SCIPY_HASH\" = \"v0.15.1\" ]] || [[ \"$SCIPY_HASH\" = \"v0.14.1\" ]]; then \
   /usr/local/bin/pip install nose==$NOSE_VER && \
   ln -sf /lib/x86_64-linux-gnu/libm-2.23.so /usr/lib/x86_64-linux-gnu/libm.so && \
   python runtests.py --mode=full --gcov -- --with-coverage --cover-package=scipy --exclude='test_gzip_py3'; fi && \
   echo 'Compiled line coverage total:' && \
   gcovr -r . | grep -i 'TOTAL' " \
  ]
