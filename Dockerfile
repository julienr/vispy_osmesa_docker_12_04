# Dockerfile to build OSMesa (and GLU) for Ubuntu 12.04

FROM ubuntu:12.04
MAINTAINER Julien Rebetez "julien.rebetez@gmail.com"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update

RUN apt-get install -y software-properties-common \
                       python-software-properties \
                       wget

# -- Add LLVM backports
# See http://llvm.org/apt/
# This also requires gcc backports for libstdc++ on 12.04
RUN wget -O - http://llvm.org/apt/llvm-snapshot.gpg.key | apt-key add - \
    && apt-add-repository -y "deb http://llvm.org/apt/precise/ llvm-toolchain-precise-3.7 main" \
    && apt-add-repository -y "ppa:ubuntu-toolchain-r/test" \
    && apt-get update

# -- Build deps
RUN apt-get install -y build-essential \
                       pkg-config \
                       libtool \
                       automake \
                       git \
                       clang-3.7 \
                       llvm-3.7 \
                       llvm-3.7-dev \
                       fontconfig \
                       python-mako
                       
# -- Download OSMesa sources and GLU
RUN wget ftp://ftp.freedesktop.org/pub/mesa/11.0.0/mesa-11.0.0-rc1.tar.gz -P /root \
    && wget ftp://ftp.freedesktop.org/pub/mesa/glu/glu-9.0.0.tar.gz -P /root

# -- Build OSMesa in /opt/osmesa_llvmpipe
ADD src/_setup/2_build_osmesa.sh /tmp/2_build_osmesa.sh
RUN /bin/bash /tmp/2_build_osmesa.sh

# -- Test OSMesa
# Because python ctypes.util.find_library relies on running "gcc -l<libname>"
# to find libraries (acting as a linker), it ignores LD_LIBRARY_PATH
# But then, when loading the library, it uses ctypes.CDLL which uses
# LD_LIBRARY_PATH Basically, we need to setup both
ENV LIBRARY_PATH=/opt/osmesa_llvmpipe/lib:$LIBRARY_PATH \
    LD_LIBRARY_PATH=/opt/osmesa_llvmpipe/lib:$LD_LIBRARY_PATH
ADD src/c_example /root/c_example
ADD src/_setup/3_test_osmesa.sh /tmp/3_test_osmesa.sh
RUN /bin/bash /tmp/3_test_osmesa.sh
