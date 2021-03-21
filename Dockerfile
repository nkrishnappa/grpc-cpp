FROM registry.access.redhat.com/ubi8/ubi:latest as builder

RUN dnf update -y && \
dnf -y install wget git gcc gcc-c++ make procps-ng  && \
dnf clean all

ARG CMAKE_VER="3.19.6"
ARG INSTALL_DIR="/root/.local"
ENV PATH="${PATH}:${INSTALL_DIR}"

RUN mkdir -p $INSTALL_DIR && \
/usr/bin/wget -q -O cmake-linux.sh https://github.com/Kitware/CMake/releases/download/v3.19.6/cmake-3.19.6-Linux-x86_64.sh && \
/usr/bin/sh cmake-linux.sh -- --skip-license --prefix=$INSTALL_DIR && $INSTALL_DIR/bin/cmake --version

RUN /usr/bin/git clone --recurse-submodules -b v1.35.0 https://github.com/grpc/grpc 
RUN cd grpc && mkdir -p cmake/build && pushd cmake/build && \
time $INSTALL_DIR/bin/cmake -DgRPC_INSTALL=ON \
    -DgRPC_BUILD_TESTS=OFF \
    ../.. && \ 
time /usr/bin/make -j && time /usr/bin/make install && popd

ARG HELLO_WORLD="/grpc/examples/cpp/helloworld/cmake/build/"
RUN cd grpc/examples/cpp/helloworld && mkdir -p cmake/build && \
pushd cmake/build && $INSTALL_DIR/bin/cmake -DCMAKE_PREFIX_PATH=$MY_INSTALL_DIR ../.. && \
/usr/bin/make -j && popd

RUN /usr/bin/cp -r /grpc/examples/cpp/helloworld/cmake/build/* $INSTALL_DIR/bin/
ENV PATH="${PATH}:${HELLO_WORLD}"
