FROM debian:trixie-slim

ARG BUILD_ARCH=amd64
ARG DEBIAN_FRONTEND=noninteractive
ARG ZABBIX_PACKAGE_SOURCE=https://repo.zabbix.com/zabbix/6.0/debian/pool/main/z/zabbix-release/zabbix-release_latest_6.0+debian13_all.deb
ARG ZABBIX_PACKAGE_SOURCE_ARM=https://repo.zabbix.com/zabbix/6.0/debian-arm64/pool/main/z/zabbix-release/zabbix-release_latest_6.0+debian13_all.deb

LABEL maintainer="ChrSchu <chr.schu@outlook.com>"

# Add Zabbix and Docker users and groups
RUN groupadd --system --gid 1995 zabbix && \
    useradd --system -g zabbix --uid 1997 zabbix && \
    groupadd --system --gid 1003 docker && \
    usermod -aG docker zabbix

# Install base dependencies
RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y install bash jq && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*

# Install Zabbix and addons
RUN apt-get -y update && apt-get -y install wget && \
    if [ "${BUILD_ARCH}" = "amd64" ]; then wget -O zabbix_repo.deb ${ZABBIX_PACKAGE_SOURCE}; fi && \
    if [ "${BUILD_ARCH}" = "aarch64" ]; then wget -O zabbix_repo.deb ${ZABBIX_PACKAGE_SOURCE_ARM}; fi && \
    dpkg -i zabbix_repo.deb && \
    rm -f zabbix_repo.deb && \
    apt-get -y update && \
    apt-get -y install zabbix-agent2 && \
    apt-get -y install zabbix-agent2-plugin-* && \
    apt-get -y purge wget && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*

# Create Zabbix folders and configure rights and service dir
RUN mkdir -p /etc/zabbix/zabbix_agentd.d && \
    mkdir -p /var/lib/zabbix/enc && \
    mkdir -p /var/lib/zabbix/modules && \
    mkdir -p /var/lib/zabbix/buffer && \
    mkdir -p /run/zabbix/agent.plugin.sock && \
    mkdir -p /usr/sbin/zabbix-agent2-plugin && \
    chown --quiet -R zabbix:zabbix /etc/zabbix/ /var/lib/zabbix/ /usr/sbin/zabbix-agent2-plugin/ /run/zabbix/ && \
    chgrp -R 0 /etc/zabbix/ /var/lib/zabbix/ /usr/sbin/zabbix-agent2-plugin/ /run/zabbix/ && \
    chmod -R g=u /etc/zabbix/ /var/lib/zabbix/ /usr/sbin/zabbix-agent2-plugin/ /run/zabbix/

# Add run script
COPY run.sh /run.sh
RUN chown zabbix:zabbix /run.sh && \
    chmod a+x /run.sh

# Expose Zabbix Agent TCP Port
EXPOSE 10050/tcp

WORKDIR /var/lib/zabbix
CMD [ "/run.sh" ]
