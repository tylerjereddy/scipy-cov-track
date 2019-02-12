# build Docker image in repo root
# with docker build -t scipy-cov .
FROM ubuntu:16.04

RUN \
  apt-get update && \
  apt-get -y upgrade

# aim for basic Python 2.7 / pip setup
RUN \
  apt-get install -y \
  gcc \
  gfortran \
  git \
  libopenblas-dev \
  liblapack-dev \
  python-pip \
  vim

RUN git clone https://github.com/scipy/scipy.git

RUN \
  pip install -U pip && \
  /usr/local/bin/pip install cython==0.28.5 numpy==1.13.3 pytest==3.1.0

#RUN \
  #cd scipy && \
  # TODO: expand handling beyond SciPy 1.0.0 hash
  #git checkout 11509c4 && \
  #python runtests.py --mode=full --coverage --gcov
