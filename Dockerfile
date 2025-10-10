# Nvidia docker
ARG CUDA_VERSION=13.0.0
FROM nvidia/cuda:${CUDA_VERSION}-devel-ubuntu22.04
SHELL ["/bin/bash", "-c"]


# Set environment
ENV CMAKE_VERSION 3.27.9
ENV CONAN_USER_HOME /root/
ENV DEBIAN_FRONTEND noninteractive
ENV TRT_LIBPATH /usr/lib/x86_64-linux-gnu
ENV TRT_VERSION 10.13.3.9

# Timezone
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN echo 'Asia/Shanghai' > /etc/timezone


# Aliyun ubuntu image source
RUN sed -i 's#http://archive.ubuntu.com/#https://mirrors.aliyun.com/#' /etc/apt/sources.list


# Update CUDA signing key
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/3bf863cc.pub


# Install UTF-8
RUN apt-get update && apt-get install -y --no-install-recommends \
    locales && locale-gen en_US.UTF-8


# Install requried libraries
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt \
    autoconf \
    bash \
    bc \
    bison \
    build-essential \
    bzip2 \
    checkpolicy \
    curl \
    devscripts \
    dh-make \
    fakeroot \
    file \
    g++ \
    gawk \
    gcc \
    git \
    git-core \
    git-lfs \
    iputils-ping \
    kmod \
    libcurl4-openssl-dev \
    libssl-dev \
    libtool \
    libzstd-dev \
    lintian \
    make \
    net-tools \
    openssl \
    patchelf \
    pbzip2 \
    perl \
    pkg-config \
    policycoreutils \
    pv \
    rsync \
    semodule-utils \
    ssh \
    ssh-client \
    sshpass \
    sudo \
    tar \
    tar \
    tree \
    udev \
    unzip \
    vim \
    wget \
    xterm \
    xxd \
    xz-utils \
    zip \
    zsh


# Install python3
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-dev \
    python3-pip \
    python3-venv \
    python3-wheel \
    && ln -s /usr/bin/python3 /usr/bin/python


# Modify pip config
RUN pip3 install -i https://mirrors.aliyun.com/pypi/simple/ --upgrade pip \
    && pip3 config set global.index-url https://mirrors.aliyun.com/pypi/simple/


# Install TensorRT
# RUN curl -L --limit-rate 10m --speed-limit 1 -O \
#     https://developer.nvidia.com/downloads/compute/machine-learning/tensorrt/10.13.3/tars/TensorRT-10.13.3.9.Linux.x86_64-gnu.cuda-13.0.tar.gz \
#     && tar -xf TensorRT-10.13.3.9.Linux.x86_64-gnu.cuda-13.0.tar.gz \
#     && cp -a TensorRT-10.13.3.9/lib/*.so* /usr/lib/x86_64-linux-gnu/ \
#     && pip install TensorRT-10.13.3.9/python/tensorrt-10.13.3.9-cp312-none-linux_x86_64.whl \
#     && rm -rf TensorRT-10.13.3.9 TensorRT-10.13.3.9.Linux.x86_64-gnu.cuda-13.0.tar.gz ;\


# Install PyPI packages
RUN pip3 install --no-cache-dir \
    conan==1.59.0 \
    jupyter \
    jupyterlab \
    numpy


# install repo
RUN curl http://mirrors.tuna.tsinghua.edu.cn/git/git-repo > /bin/repo && chmod +x /bin/repo


# install cmake
RUN curl -L --speed-limit 1 -O https://githubfast.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz && \
    tar -xf cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz && \
    rm cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz
RUN rm -rf cmake-${CMAKE_VERSION}-linux-x86_64/man && \
    cp -r cmake-${CMAKE_VERSION}-linux-x86_64/* /usr/ && \
    rm -rf cmake-${CMAKE_VERSION}-linux-x86_64


RUN apt-get -y autoremove --purge && \
    apt-get autoclean -y && \
    apt-get clean -y && \
    find /var/lib/apt/lists -type f -delete && \
    find /var/cache -type f -delete && \
    find /var/log -type f -delete && \
    find /usr/share/doc -type f -delete && \
    find /usr/share/man -type f -delete

