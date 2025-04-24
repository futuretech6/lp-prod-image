FROM --platform=$BUILDPLATFORM centos:7

ARG TARGETOS
ARG TARGETARCH

# directory for installing dependencies
ENV TMP_DIR=/tmp

# default mount directory
ENV WORKSPACE=/workspace

# centos mirrors
RUN curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
# RUN sed -i 's|http://|https://|g' /etc/yum.repos.d/CentOS-Base.repo
RUN yum makecache

# epel mirrors
RUN yum update -y --skip-broken
RUN yum install -y epel-release
RUN curl -o /etc/yum.repos.d/epel.repo https://mirrors.aliyun.com/repo/epel-7.repo
# RUN sed -i 's|http://|https://|g' /etc/yum.repos.d/epel.repo

# dev tools
RUN yum groupinstall -y "Development Tools"

# tar
RUN yum install -y tar

# boost
WORKDIR $TMP_DIR
RUN yum install -y which python2-devel
RUN curl -LO https://archives.boost.io/release/1.67.0/source/boost_1_67_0.tar.gz && \
    tar -zxf boost_1_67_0.tar.gz && \
    cd boost_1_67_0 && \
    ./bootstrap.sh --with-python=/usr/bin/python2.7 --prefix=/usr/ && \
    ./b2 install -j$(nproc) && \
    rm -rf $TMP_DIR
RUN ln -s /lib/libboost_python27.so /lib/libboost_python.so

# protobuf
WORKDIR $TMP_DIR
RUN curl -LO https://github.com/protocolbuffers/protobuf/releases/download/v3.7.1/protobuf-cpp-3.7.1.tar.gz && \
    tar -zxf protobuf-cpp-3.7.1.tar.gz && \
    cd protobuf-3.7.1 && \
    ./autogen.sh && \
    ./configure && \
    make -j$(nproc) && \
    make -j$(nproc) check && \
    make install && \
    rm -rf $TMP_DIR

# cmake
WORKDIR $TMP_DIR
RUN yum install -y openssl-devel
RUN curl -LO https://cmake.org/files/v3.27/cmake-3.27.9.tar.gz && \
    tar -zxf cmake-3.27.9.tar.gz && \
    cd cmake-3.27.9 && \
    ./bootstrap --parallel=$(nproc) && \
    make -j$(nproc) && \
    make -j$(nproc) install && \
    rm -rf $TMP_DIR

# gcc
# use "-DCMAKE_CXX_COMPILER=/opt/rh/devtoolset-7/root/usr/bin/g++" for cmake
# or "source /opt/rh/devtoolset-7/enable" for bash
RUN yum install -y centos-release-scl
RUN sed -e 's|^mirrorlist=|# mirrorlist=|g' \
        -e 's|^#\s*baseurl=http://mirror.centos.org|baseurl=https://mirrors.aliyun.com|g' \
        -i /etc/yum.repos.d/CentOS-SCLo-scl*.repo
RUN yum install -y devtoolset-7

# other dependencies
RUN yum install -y uriparser-devel        # `#include <uniparser/xxx>`
RUN yum install -y elfutils-libelf-devel  # -lelf

# other tools
RUN yum install -y vim sudo

# cleanup
# RUN rm -rf $TMP_DIR
# RUN yum clean all && rm -rf /var/cache/yum

# gosu
ENV GOSU_VERSION=1.14
RUN curl -Lo /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-${TARGETARCH}" \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true

# entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# default command
WORKDIR $WORKSPACE
CMD ["/bin/bash"]
