#!/bin/bash
# Progra:
# This program is for deleting all the settings.
# History:
# 2019/11/2 nxshen First release
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
echo "\nHello there, it a shell script for deleting all the settings\n"

# 停止所有服務
systemctl stop apache2.service
systemctl stop isc-dhcp-server.service
systemctl stop hostapd.service 
sudo systemctl restart networking

# 清除所有防火牆資料
iptables -Z
iptables -F
iptables -X
iptables -t nat -Z
iptables -t nat -F
iptables -t nat -X

exit 0
