# Nvidia docker
ARG CUDA_VERSION=12.8.0
FROM nvidia/cuda:${CUDA_VERSION}-devel-ubuntu24.04
SHELL ["/bin/bash", "-c"]
ENV DEBIAN_FRONTEND noninteractive

# Timezone
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN echo 'Asia/Shanghai' > /etc/timezone

# Aliyun ubuntu image source
RUN sed -i -e 's#http://archive.ubuntu.com/#https://mirrors.aliyun.com/#g' \
    -e 's#http://cn.archive.ubuntu.com/#https://mirrors.aliyun.com/#g' \
    -e 's#http://security.ubuntu.com/#https://mirrors.aliyun.com/#g' \
    /etc/apt/sources.list /etc/apt/sources.list.d/ubuntu.sources

# Update CUDA signing key
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/3bf863cc.pub

# Install UTF-8
RUN apt-get update && apt-get install -y --no-install-recommends \
    locales && locale-gen en_US.UTF-8

# Install requried libraries
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt \
    aria2 \
    autoconf \
    bash \
    bc \
    bison \
    build-essential \
    bzip2 \
    checkpolicy \
    cudnn-cuda-12 \
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
    iproute2 \
    iputils-ping \
    kmod \
    libcurl4-openssl-dev \
    libssl-dev \
    libtool \
    libzstd-dev \
    lintian \
    make \
    net-tools \
    openjdk-17-jdk \
    openssl \
    patchelf \
    pbzip2 \
    perl \
    pkg-config \
    policycoreutils \
    pv \
    rsync \
    semodule-utils \
    socat \
    ssh \
    ssh-client \
    sshpass \
    sudo \
    tar \
    tcpdump \
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

# Create python3 virtualenv
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Modify pip config
RUN pip3 install -i https://mirrors.aliyun.com/pypi/simple/ --upgrade pip \
    && pip3 config set global.index-url https://mirrors.aliyun.com/pypi/simple/

# Install PyPI packages
RUN pip3 install --no-cache-dir \
    --extra-index-url https://download.pytorch.org/whl/cu128 \
    --extra-index-url https://pypi.nvidia.com \
    conan==2.22.1 \
    facenet_pytorch \
    huggingface-hub \
    nvidia-modelopt[all] \
    onnx \
    onnx_graphsurgeon \
    onnxmltools \
    onnxruntime-gpu \
    onnxscript \
    onnxslim \
    opencv-python \
    pycuda \
    pytest \
    scikit-image \
    scikit-learn \
    torch-tensorrt==2.8.0 \
    torch==2.8.0+cu128 \
    torchaudio==2.8.0+cu128 \
    torchvision==0.23.0+cu128 \
    ultralytics

# install repo
RUN curl http://mirrors.tuna.tsinghua.edu.cn/git/git-repo > /bin/repo && chmod +x /bin/repo

# install cmake
ENV CMAKE_VERSION 3.27.9
RUN curl -L --speed-limit 1 -O https://githubfast.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz && \
    tar -xf cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz && \
    rm cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz
RUN rm -rf cmake-${CMAKE_VERSION}-linux-x86_64/man && \
    cp -r cmake-${CMAKE_VERSION}-linux-x86_64/* /usr/ && \
    rm -rf cmake-${CMAKE_VERSION}-linux-x86_64

# Install arm gnu toolchain
ENV PATH="/opt/arm-none-linux-gnueabihf/bin:${PATH}"
RUN aria2c -c -x 16 -s 16 --retry-wait=5 --max-tries=0 \
    https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu/11.2-2022.02/binrel/gcc-arm-11.2-2022.02-x86_64-arm-none-linux-gnueabihf.tar.xz \
    && tar -xf gcc-arm-11.2-2022.02-x86_64-arm-none-linux-gnueabihf.tar.xz -C /opt \
    && mv /opt/gcc-arm-11.2-2022.02-x86_64-arm-none-linux-gnueabihf /opt/arm-none-linux-gnueabihf \
    && rm gcc-arm-11.2-2022.02-x86_64-arm-none-linux-gnueabihf.tar.xz

ENV PATH="/opt/aarch64-none-linux-gnu/bin:${PATH}"
RUN aria2c -c -x 16 -s 16 --retry-wait=5 --max-tries=0 \
    https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu-a/10.2-2020.11/binrel/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu.tar.xz \
    && tar -xf gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu.tar.xz -C /opt \
    && mv /opt/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu /opt/aarch64-none-linux-gnu \
    && rm gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu.tar.xz

# Install TensorRT
ENV TRT_LIBPATH /usr/lib/x86_64-linux-gnu
ENV TRT_VERSION 10.13.3.9
RUN aria2c -c -x 16 -s 16 --retry-wait=5 --max-tries=0 \
    https://developer.nvidia.com/downloads/compute/machine-learning/tensorrt/10.13.3/tars/TensorRT-10.13.3.9.Linux.x86_64-gnu.cuda-12.9.tar.gz \
    && tar -xf TensorRT-10.13.3.9.Linux.x86_64-gnu.cuda-12.9.tar.gz \
    && cp -a TensorRT-10.13.3.9/bin/* /usr/bin/ \
    && cp -a TensorRT-10.13.3.9/lib/*.so* /usr/lib/x86_64-linux-gnu \
    && cp -a TensorRT-10.13.3.9/include/* /usr/include/x86_64-linux-gnu \
    && pip3 install TensorRT-10.13.3.9/python/tensorrt-10.13.3.9-cp312-none-linux_x86_64.whl \
    && rm -rf TensorRT-10.13.3.9 TensorRT-10.13.3.9.Linux.x86_64-gnu.cuda-12.9.tar.gz

RUN apt-get -y autoremove --purge && \
    apt-get autoclean -y && \
    apt-get clean -y && \
    find /var/lib/apt/lists -type f -delete && \
    find /var/cache -type f -delete && \
    find /var/log -type f -delete && \
    find /usr/share/doc -type f -delete && \
    find /usr/share/man -type f -delete

ARG UNAME=sky
RUN usermod -l ${UNAME} -d /home/${UNAME} -m ubuntu && \
    groupmod -n ${UNAME} ubuntu && \
    echo "${UNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER ${UNAME}
ENV CONAN_USER_HOME /home/${UNAME}
ENV LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:/usr/local/lib:${LD_LIBRARY_PATH}"
