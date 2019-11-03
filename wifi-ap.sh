#!/bin/bash
# Progra:
# This program is for hostapd, dhcp server and web-based login authenticaion, which is used to set iptable.
# History:
# 2019/11/2 nxshen First release
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
echo "\nHello there, it a shell script for establishing a wifi hot spot~\n"

sudo apt update
sudo apt install lamp-server^
sudo apt install isc-dhcp-server
sudo apt install dnsmasq

cp auth.cpp /usr/lib/cgi-bin/
make
cp auth.cgi /usr/lib/cgi-bin/
cp makefile /usr/lib/cgi-bin/
cp dhcpd.conf /etc/dhcp/
cp hostapd.conf /etc/hostapd/
cp bookmarks.html /home/
cp setIptables /home/
cp index.html /var/www/html/
cp isc-dhcp-server /etc/default/
cp dhcpd.conf /etc/dhcp/
cp interfaces /etc/network/

systemctl start apache2.service
systemctl enable apache2.service
systemctl start isc-dhcp-server.service
systemctl enable isc-dhcp-server.service
systemctl start mysql.service
systemctl enable mysql.service
sudo ufw allow  67/udp
sudo ufw reload
sudo ufw show
sudo systemctl restart networking

systemctl start hostapd.service 

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
iptables -A FORWARD -i wlxf48ceb9ba387 -j WD_wlan0_Internet
iptables -A FORWARD -i wlp2s0 -o wlxf48ceb9ba387 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i wlxf48ceb9ba387 -o wlp2s0 -j ACCEPT
iptables -A WD_wlan0_AuthServs -d 10.10.0.1/32 -j ACCEPT
iptables -A WD_wlan0_Internet -m state --state INVALID -j DROP
iptables -A WD_wlan0_Internet -o wlp2s0 -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
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
iptables --table nat --append POSTROUTING --out-interface wlxf48ceb9ba387 -j MASQUERADE

exit 0
