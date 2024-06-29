ARG BUILD_VERSION
ARG BUILD_BASE_IMAGE=debian:bookworm

FROM ${BUILD_BASE_IMAGE}

ARG BUILD_ARCH=amd64

LABEL maintainer "ChrSchu <chr.schu@outlook.com>"

ENV LANG C.UTF-8
ENV TERM=xterm
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Add Zabbix users and groups
RUN groupadd --system --gid 1995 zabbix && \
    useradd --system -g zabbix --uid 1997 zabbix

# Add Home Assistant docker group and add Zabbix user
RUN groupadd --system --gid 1003 docker && \
    usermod -aG docker zabbix

# Install base dependencies
RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y install bash jq wget dpkg sudo && \
    apt-get -y autoremove && \
    apt-get -y clean

# Install Zabbix
RUN echo "zabbix ALL=(root) NOPASSWD: /update.sh" >> /etc/sudoers.d/zabbix && \
    if [[ "${BUILD_ARCH}" = "amd64" ]]; then wget -O zabbix_repo.deb https://repo.zabbix.com/zabbix/7.0/debian/pool/main/z/zabbix-release/zabbix-release_7.0-1+debian12_all.deb; fi && \
    if [[ "${BUILD_ARCH}" == "aarch64" ]]; then wget -O zabbix_repo.deb https://repo.zabbix.com/zabbix/7.0/debian-arm64/pool/main/z/zabbix-release/zabbix-release_7.0-1+debian12_all.deb; fi && \
    dpkg -i zabbix_repo.deb && \
    rm -f zabbix_repo.deb && \
    apt-get -y update && \
    apt-get -y install zabbix-agent2 zabbix-agent2-plugin-postgresql zabbix-agent2-plugin-mongodb

# Create Zabbix folders and configure rights
RUN mkdir -p /etc/zabbix/zabbix_agentd.d && \
    mkdir -p /var/lib/zabbix/enc && \
    mkdir -p /var/lib/zabbix/modules && \
    mkdir -p /var/lib/zabbix/buffer && \
    mkdir -p /run/zabbix/agent.plugin.sock && \
    mkdir -p /usr/sbin/zabbix-agent2-plugin && \
    chown --quiet -R zabbix:zabbix /etc/zabbix/ /var/lib/zabbix/ /usr/sbin/zabbix-agent2-plugin/ /run/zabbix/ && \
    chgrp -R 0 /etc/zabbix/ /var/lib/zabbix/ /usr/sbin/zabbix-agent2-plugin/ /run/zabbix/ && \
    chmod -R g=u /etc/zabbix/ /var/lib/zabbix/ /usr/sbin/zabbix-agent2-plugin/ /run/zabbix/

# Add run and update script to update the configuration and start the zabbix-agent
COPY run.sh /
COPY update.sh /
RUN chown zabbix:zabbix /run.sh && \ 
    chmod a+x /run.sh && \ 
    chown zabbix:zabbix /update.sh && \ 
    chmod a+x /update.sh

EXPOSE 10050/TCP

WORKDIR /var/lib/zabbix
CMD [ "/run.sh" ]