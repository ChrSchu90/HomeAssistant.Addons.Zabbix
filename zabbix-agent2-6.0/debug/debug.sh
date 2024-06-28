#!/bin/bash

DOCKER_FILE="zabbix-agent2-6.0/Dockerfile"
CONTAINER_NAME="zabbix-agent2-6.0"
IMAGE_NAME="ha_zabbixagent2-6.0:dev"

docker build --no-cache --pull --rm -f ${DOCKER_FILE} -t ${IMAGE_NAME} ${CONTAINER_NAME} && \
    docker run --rm -it -v ./zabbix-agent2-6.0/debug/data:/data ${IMAGE_NAME}