#!/bin/bash
cd "$(dirname "$0")" || exit

DOCKER_FILE="Dockerfile"
IMAGE_NAME="zabbix70-agent2:dev"
BUILD_VERSION=0.0.1
BUILD_ARCH=amd64

docker build --no-cache --pull --rm --build-arg BUILD_VERSION="${BUILD_VERSION}" --build-arg BUILD_ARCH=${BUILD_ARCH} -f ${DOCKER_FILE} -t ${IMAGE_NAME} . && \
    docker run --rm -it -v ./debug:/data ${IMAGE_NAME}