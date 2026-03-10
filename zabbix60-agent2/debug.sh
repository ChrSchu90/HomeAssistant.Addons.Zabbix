#!/bin/bash
cd "$(dirname "$0")" || exit

DOCKER_FILE="Dockerfile"
IMAGE_NAME="zabbix60-agent2:dev"

docker build --no-cache --pull --rm -f ${DOCKER_FILE} -t ${IMAGE_NAME} . && \
    docker run --rm -it -v ./debug:/data ${IMAGE_NAME}