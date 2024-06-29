#!/bin/bash

DOCKER_FILE="zabbix60-agent2/Dockerfile"
CONTAINER_NAME="zabbix60-agent2"
IMAGE_NAME="zabbix60-agent2:dev"

docker build --no-cache --pull --rm -f ${DOCKER_FILE} -t ${IMAGE_NAME} ${CONTAINER_NAME} && \
    docker run --rm -it -v ./zabbix60-agent2/debug/data:/data ${IMAGE_NAME}