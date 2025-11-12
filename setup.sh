#!/bin/bash
set -e

DOCKER_IMAGE="sky-docker"
DOCKER_CONTAINER="sky-docker"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE="$(cd $PROJECT_DIR/.. && pwd)"
if [[ -n "$1" && -d "$1" ]]; then
    WORKSPACE="$(realpath "$1")"
fi

if ! docker ps -a --format '{{.Names}}' | grep -qw $DOCKER_CONTAINER; then
    mkdir -p $WORKSPACE/p
    docker build -t $DOCKER_IMAGE $PROJECT_DIR \
        --build-arg UNAME=$USER
    docker run --rm -it --gpus all --privileged --name $DOCKER_CONTAINER --network host \
        -v $WORKSPACE:/home/$USER/source \
        -v $PROJECT_DIR/.conan2:/home/$USER/.conan2 \
        -v $PROJECT_DIR/.conan2:/root/.conan2 \
        -v $WORKSPACE/p:/home/$USER/.conan2/p \
        -v $WORKSPACE/p:/root/.conan2/p \
        -v $HOME/.ssh:/home/$USER/.ssh \
        -v /dev/bus/usb:/dev/bus/usb \
        -v /etc/localtime:/etc/localtime:ro \
        -w /home/$USER/source $DOCKER_IMAGE:latest /bin/bash
else
    docker exec -it $DOCKER_CONTAINER /bin/bash
fi
