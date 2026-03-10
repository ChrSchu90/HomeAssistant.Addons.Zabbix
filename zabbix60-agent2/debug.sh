#!/bin/bash
cd "$(dirname "$0")" || exit

DOCKER_FILE="Dockerfile"
IMAGE_NAME="zabbix60-agent2:dev"
BUILD_VERSION=0.0.1
BUILD_ARCH=amd64
BUILD_FROM=ghcr.io/home-assistant/amd64-base-debian:trixie

docker build --no-cache --pull --rm --build-arg BUILD_VERSION="${BUILD_VERSION}" --build-arg BUILD_ARCH=${BUILD_ARCH} --build-arg BUILD_FROM=${BUILD_FROM} -f ${DOCKER_FILE} -t ${IMAGE_NAME} . && \
    docker run --rm -it -v ./debug:/data ${IMAGE_NAME}