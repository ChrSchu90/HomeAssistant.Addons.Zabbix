#!/bin/bash
set -euo pipefail

# Update-or-append helper (handles existing commented or uncommented keys too)
set_ini_kv() {
  local file="$1" key="$2" value="$3"
  if grep -qE "^[[:space:]]*#?[[:space:]]*${key}=" "$file"; then
    sed -i -E "s|^[[:space:]]*#?[[:space:]]*(${key})=.*|\1=${value}|" "$file"
  else
    printf '%s=%s\n' "$key" "$value" >> "$file"
  fi
}

# Remove ini key and value
remove_ini_key() {
  local file="$1" key="$2"
  sed -i -E "/^[[:space:]]*#?[[:space:]]*${key}=/d" "$file"
}

# Update required zabbix-agent config
ADDON_CONFIG_FILE=/data/options.json
ZABBIX_CONFIG_FILE=/etc/zabbix/zabbix_agent2.conf
set_ini_kv "$ZABBIX_CONFIG_FILE" "Server"       "$(jq -r '.server // empty' "${ADDON_CONFIG_FILE}")"
set_ini_kv "$ZABBIX_CONFIG_FILE" "ServerActive" "$(jq -r '.serveractive // empty' "${ADDON_CONFIG_FILE}")"
set_ini_kv "$ZABBIX_CONFIG_FILE" "Hostname"     "$(jq -r '.hostname // empty' "${ADDON_CONFIG_FILE}")"
set_ini_kv "$ZABBIX_CONFIG_FILE" "DebugLevel"   "$(jq -r '.loglevel // empty' "${ADDON_CONFIG_FILE}")"
set_ini_kv "$ZABBIX_CONFIG_FILE" "LogType"      "console"

# Enable PSK if both identity AND secret are non-empty
ZABBIX_TLSPSK_IDENTITY=$(jq -r '.tlspskidentity // empty' "${ADDON_CONFIG_FILE}")
ZABBIX_TLSPSK_SECRET=$(jq -r '.tlspsksecret // empty' "${ADDON_CONFIG_FILE}")
if [ -n "${ZABBIX_TLSPSK_IDENTITY}" ] && [ -n "${ZABBIX_TLSPSK_SECRET}" ]; then
  ZABBIX_TLSPSK_SECRET_FILE=/etc/zabbix/tls_secret
  printf '%s' "${ZABBIX_TLSPSK_SECRET}" > "${ZABBIX_TLSPSK_SECRET_FILE}"
  set_ini_kv "$ZABBIX_CONFIG_FILE" "TLSConnect"     "psk"
  set_ini_kv "$ZABBIX_CONFIG_FILE" "TLSAccept"      "psk"
  set_ini_kv "$ZABBIX_CONFIG_FILE" "TLSPSKIdentity" "${ZABBIX_TLSPSK_IDENTITY}"
  set_ini_kv "$ZABBIX_CONFIG_FILE" "TLSPSKFile"     "${ZABBIX_TLSPSK_SECRET_FILE}"
else
  # Remove TLS config completely if not configured
  remove_ini_key "$ZABBIX_CONFIG_FILE" "TLSConnect"
  remove_ini_key "$ZABBIX_CONFIG_FILE" "TLSAccept"
  remove_ini_key "$ZABBIX_CONFIG_FILE" "TLSPSKIdentity"
  remove_ini_key "$ZABBIX_CONFIG_FILE" "TLSPSKFile"
fi

# unset secrets from env
unset ZABBIX_TLSPSK_IDENTITY
unset ZABBIX_TLSPSK_SECRET

exec /usr/sbin/zabbix_agent2 --foreground -c "${ZABBIX_CONFIG_FILE}"