# build Docker image in repo root
# with docker build -t scipy-cov .
FROM ubuntu:16.04

RUN \
  apt-get update && \
  apt-get -y upgrade

# aim for basic Python 2.7 / pip setup
RUN \
  apt-get install -y \
  git \
  python-pip \
  vim

RUN \
  pip install -U pip
