#!/bin/bash
set -x
WORKSPACE="$HOME/learn/conan"
TOOLS="$HOME/tools"
CONAN_ROOT="$WORKSPACE/conan_root"
DOCKER_IMAGE="sky-docker"
DOCKER_CONTAINER="conan-docker"

mkdir -p $WORKSPACE/data

docker build -t $DOCKER_IMAGE $CONAN_ROOT
docker run --rm -it --gpus all --privileged --name $DOCKER_CONTAINER --network host \
    -v $WORKSPACE:$HOME/source \
    -v $WORKSPACE/conan_root/.conan:/root/.conan \
    -v $WORKSPACE/data:/root/.conan/data \
    -v $HOME/.ssh:$HOME/.ssh \
    -v /dev/bus/usb:/dev/bus/usb \
    -v /etc/localtime:/etc/localtime:ro \
    -w $HOME/source $DOCKER_IMAGE:latest /bin/bash
