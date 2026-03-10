#!/bin/bash
set -euo pipefail

# Extract config data (missing -> empty)
CONFIG_PATH=/data/options.json
ZABBIX_SERVER=$(jq -r '.server // empty' "${CONFIG_PATH}")
ZABBIX_SERVER_ACTIVE=$(jq -r '.serveractive // empty' "${CONFIG_PATH}")
ZABBIX_HOSTNAME=$(jq -r '.hostname // empty' "${CONFIG_PATH}")
ZABBIX_TLSPSK_IDENTITY=$(jq -r '.tlspskidentity // empty' "${CONFIG_PATH}")
ZABBIX_TLSPSK_SECRET=$(jq -r '.tlspsksecret // empty' "${CONFIG_PATH}")
LOG_LEVEL=$(jq -r '.loglevel // empty' "${CONFIG_PATH}")

# helper: escape replacement for sed (escapes @ and & and backslashes)
escape_sed_replacement() {
  printf '%s' "$1" | sed -e 's/[\/&@\\]/\\&/g'
}

# Update zabbix-agent config
ZABBIX_CONFIG_FILE=/etc/zabbix/zabbix_agent2.conf
echo "DebugLevel=${LOG_LEVEL}" >> "${ZABBIX_CONFIG_FILE}"
echo "LogType=console" >> "${ZABBIX_CONFIG_FILE}"
sed -i "s@^\(Server\)=.*@\1=$(escape_sed_replacement "${ZABBIX_SERVER}")@" "${ZABBIX_CONFIG_FILE}"
sed -i "s@^\(ServerActive\)=.*@\1=$(escape_sed_replacement "${ZABBIX_SERVER_ACTIVE}")@" "${ZABBIX_CONFIG_FILE}"
sed -i "s@^#\?\s\?\(Hostname\)=.*@\1=$(escape_sed_replacement "${ZABBIX_HOSTNAME}")@" "${ZABBIX_CONFIG_FILE}"

# Only enable PSK if both identity AND secret are non-empty
if [ -n "${ZABBIX_TLSPSK_IDENTITY}" ] && [ -n "${ZABBIX_TLSPSK_SECRET}" ]; then
  ZABBIX_TLSPSK_SECRET_FILE=/etc/zabbix/tls_secret
  printf '%s' "${ZABBIX_TLSPSK_SECRET}" > "${ZABBIX_TLSPSK_SECRET_FILE}"
  sed -i "s@^#\?\s\?\(TLSConnect\)=.*@\1=psk@" "${ZABBIX_CONFIG_FILE}"
  sed -i "s@^#\?\s\?\(TLSAccept\)=.*@\1=psk@" "${ZABBIX_CONFIG_FILE}"
  sed -i "s@^#\?\s\?\(TLSPSKIdentity\)=.*@\1=$(escape_sed_replacement "${ZABBIX_TLSPSK_IDENTITY}")@" "${ZABBIX_CONFIG_FILE}"
  sed -i "s@^#\?\s\?\(TLSPSKFile\)=.*@\1=$(escape_sed_replacement "${ZABBIX_TLSPSK_SECRET_FILE}")@" "${ZABBIX_CONFIG_FILE}"
fi

# unset secrets from env
unset ZABBIX_TLSPSK_IDENTITY
unset ZABBIX_TLSPSK_SECRET

exec /usr/sbin/zabbix_agent2 --foreground -c "${ZABBIX_CONFIG_FILE}"