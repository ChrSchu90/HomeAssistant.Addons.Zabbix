#!/bin/bash

DOCKER_FILE="zabbix70-agent2/Dockerfile"
CONTAINER_NAME="zabbix70-agent2"
IMAGE_NAME="zabbix70-agent2:dev"

docker build --no-cache --pull --rm -f ${DOCKER_FILE} -t ${IMAGE_NAME} ${CONTAINER_NAME} && \
    docker run --rm -it -v ./zabbix70-agent2/debug/data:/data ${IMAGE_NAME}