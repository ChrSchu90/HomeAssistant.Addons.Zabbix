# Home Assistant Zabbix Addons
[![Build](https://github.com/ChrSchu90/HomeAssistant.Addons.Zabbix/actions/workflows/build.yml/badge.svg)](https://github.com/ChrSchu90/HomeAssistant.Addons.Zabbix/actions/workflows/build.yml)

[Add-ons for Home Assistant](https://www.home-assistant.io/addons/) that allow you to install [Zabbix](https://www.zabbix.com/) services.

## Installation

Follow these steps to get the add-on installed on your system:

1. Navigate in your Home Assistant frontend to **Settings** -> **Add-ons** -> **Add-on store**.
2. Add the repository `https://github.com/ChrSchu90/HomeAssistant.Addons.Zabbix`
3. Find the "zabbix-agent2 ..." add-on and click it.
4. Click on the "INSTALL" button.

## How to use

1. In the configuration section, set the `Server IP` and `Host Name`.
3. Disable the `Protection mode` inside the Info tab.
4. Start the add-on.
5. Check the add-on log output to see if the agent is running.

## How to update

`Major` updated are separated into different addons, you need to stop the old addon to run the new major version.

`Minor` updated can be applied by rebuilding the addon.
![](Documentation/Screenshots/Rebuild.jpg)