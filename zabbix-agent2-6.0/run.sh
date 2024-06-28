#!/bin/bash
# shellcheck shell=dash


# Extract config data
CONFIG_PATH=/data/options.json
ZABBIX_SERVER=$(jq --raw-output ".server" "${CONFIG_PATH}")
ZABBIX_SERVER_ACTIVE=$(jq --raw-output ".serveractive" "${CONFIG_PATH}")
ZABBIX_HOSTNAME=$(jq --raw-output ".hostname" "${CONFIG_PATH}")
ZABBIX_TLSPSK_IDENTITY=$(jq --raw-output ".tlspskidentity" "${CONFIG_PATH}")
ZABBIX_TLSPSK_SECRET=$(jq --raw-output ".tlspsksecret" "${CONFIG_PATH}")
AUTO_UPDATE=$(jq --raw-output ".autoupdate" "$CONFIG_PATH")
LOG_LEVEL=$(jq --raw-output ".loglevel" "$CONFIG_PATH")

# Update zabbix agent if configured
if [[ "${AUTO_UPDATE}" == "true" ]]; then
  echo "Check for updates..."
	sudo /update.sh
else
  echo "Skip update"
fi

# Update zabbix-agent config
ZABBIX_CONFIG_FILE=/etc/zabbix/zabbix_agent2.conf
echo "DebugLevel=${LOG_LEVEL}" >> "${ZABBIX_CONFIG_FILE}"
echo "LogType=console" >> "${ZABBIX_CONFIG_FILE}"
sed -i 's@^\(Server\)=.*@\1='"${ZABBIX_SERVER}"'@' "${ZABBIX_CONFIG_FILE}"
sed -i 's@^\(ServerActive\)=.*@\1='"${ZABBIX_SERVER_ACTIVE}"'@' "${ZABBIX_CONFIG_FILE}"
sed -i 's@^#\?\s\?\(Hostname\)=.*@\1='"${ZABBIX_HOSTNAME}"'@' "${ZABBIX_CONFIG_FILE}"

# Add TLS PSK config if variables are used
if [ "${ZABBIX_TLSPSK_IDENTITY}" != "null" ] && [ "${ZABBIX_TLSPSK_SECRET}" != "null" ]; then
  ZABBIX_TLSPSK_SECRET_FILE=/etc/zabbix/tls_secret
  echo "${ZABBIX_TLSPSK_SECRET}" > "${ZABBIX_TLSPSK_SECRET_FILE}"
  sed -i 's@^#\?\s\?\(TLSConnect\)=.*@\1='"psk"'@' "${ZABBIX_CONFIG_FILE}"
  sed -i 's@^#\?\s\?\(TLSAccept\)=.*@\1='"psk"'@' "${ZABBIX_CONFIG_FILE}"
  sed -i 's@^#\?\s\?\(TLSPSKIdentity\)=.*@\1='"${ZABBIX_TLSPSK_IDENTITY}"'@' "${ZABBIX_CONFIG_FILE}"
  sed -i 's@^#\?\s\?\(TLSPSKFile\)=.*@\1='"${ZABBIX_TLSPSK_SECRET_FILE}"'@' "${ZABBIX_CONFIG_FILE}"
fi
unset ZABBIX_TLSPSK_IDENTITY
unset ZABBIX_TLSPSK_SECRET

# Run zabbix-agent2 in foreground
#echo "Current user is $(id) $(echo $UID)"
#read  -n 1 -p "Input Selection:" mainmenuinput
exec /usr/sbin/zabbix_agent2 --foreground -c ${ZABBIX_CONFIG_FILE}