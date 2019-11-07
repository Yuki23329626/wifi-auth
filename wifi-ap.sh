#!/bin/bash
# Progra:
# This program will set up a wifi access point with a web-based authentication and also set up the iptables.
# History:
# 2019/11/8 nxshen add several comments
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
echo "\nHello there, it's a shell script for establishing a wifi access point~\n"

# 設定網卡ID
LAN_INTERFACE=wlp2s0
WAN_INTERFACE=wlxd037453d9c6a

# 安裝 lamp-server(linux 上的 apache+mysql+php 組合包)、
# 安裝 dhcp-server(動態分配內網 IP 的 server)、dnsmasq(DNS server 貌似沒卵用)
sudo apt update
sudo apt install lamp-server^
sudo apt install isc-dhcp-server
sudo apt install dnsmasq

# 把 config files 直接放到他們該在的地方，記得修改各自 config file 內的網卡名稱設定
cp auth.cpp /usr/lib/cgi-bin/
cp auth.cgi /usr/lib/cgi-bin/
cp makefile /usr/lib/cgi-bin/
# 要先安裝完成 mysql 才能成功編譯，auth.cpp 會用到 mysql 的 library
make
cp dhcpd.conf /etc/dhcp/
cp hostapd.conf /etc/hostapd/
cp bookmarks.html /home/
cp setIptables /home/
cp index.html /var/www/html/
cp isc-dhcp-server /etc/default/
cp dhcpd.conf /etc/dhcp/
cp interfaces /etc/network/

# 啟動該啟動的服務們並且設為開機啟動
systemctl start apache2.service
systemctl enable apache2.service
systemctl start isc-dhcp-server.service
systemctl enable isc-dhcp-server.service
systemctl start mysql.service
systemctl enable mysql.service
systemctl stop dnsmasq.service
sudo ufw allow  67/udp
sudo ufw reload
sudo ufw show
sudo systemctl restart networking

systemctl start hostapd.service 
systemctl enable hostapd.service 

# iptables 防火牆設定，有滿多是沒用的設定，本來想用類似 DNS 綁架的方式重導向驗證網頁，不知道怎麼設定~
# 驗證網頁是: 10.10.0.1/index.html，應該也可以設定 /etc/hosts 來給他一個名稱
# 以下設定的 code 取自 wifidog iptables 設定，一樣記得修改網卡ID
# Reference url: http://blog.changyy.org/2017/02/captive-portal-iptables.html
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -N WD_wlan0_AuthServs
iptables -N WD_wlan0_Global
iptables -N WD_wlan0_Internet
iptables -N WD_wlan0_Known
iptables -N WD_wlan0_Locked
iptables -N WD_wlan0_Unknown
iptables -N WD_wlan0_Validate
iptables -A FORWARD -i WAN_INTERFACE -j WD_wlan0_Internet
iptables -A FORWARD -i LAN_INTERFACE -o WAN_INTERFACE -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i WAN_INTERFACE -o LAN_INTERFACE -j ACCEPT
iptables -A WD_wlan0_AuthServs -d 10.10.0.1/32 -j ACCEPT
iptables -A WD_wlan0_Internet -m state --state INVALID -j DROP
iptables -A WD_wlan0_Internet -o LAN_INTERFACE -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
iptables -A WD_wlan0_Internet -j WD_wlan0_AuthServs
iptables -A WD_wlan0_Internet -m mark --mark 0x254 -j WD_wlan0_Locked
iptables -A WD_wlan0_Internet -j WD_wlan0_Global
iptables -A WD_wlan0_Internet -m mark --mark 0x1 -j WD_wlan0_Validate
iptables -A WD_wlan0_Internet -m mark --mark 0x2 -j WD_wlan0_Known
iptables -A WD_wlan0_Internet -j WD_wlan0_Unknown
iptables -A WD_wlan0_Known -j ACCEPT
iptables -A WD_wlan0_Locked -j REJECT --reject-with icmp-port-unreachable
iptables -A WD_wlan0_Unknown -p udp -m udp --dport 53 -j ACCEPT
iptables -A WD_wlan0_Unknown -p tcp -m tcp --dport 53 -j ACCEPT
iptables -A WD_wlan0_Unknown -p udp -m udp --dport 67 -j ACCEPT
iptables -A WD_wlan0_Unknown -p tcp -m tcp --dport 67 -j ACCEPT
iptables -A WD_wlan0_Unknown -j REJECT --reject-with icmp-port-unreachable
iptables -A WD_wlan0_Validate -j ACCEPT

# 允許 NAT 上的 IP 可以轉換成外部IP(規則:MASQUERADE)，與外網溝通
iptables --table nat --append POSTROUTING --out-interface WAN_INTERFACE -j MASQUERADE

exit 0
